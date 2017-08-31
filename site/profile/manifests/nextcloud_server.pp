# == Class: profile::nextcloud_server
#
# Profile for NextCloud server instances.
#
# === Parameters
#
# [*sites*]
#   An array of hashes containing fqdn, ssl key, and other settings. Each array element creates a NextCloud-ready vhost.
#
class profile::nextcloud_server (
  Array $sites,
) {
  $ssl_certs_dir = $::apache::params::ssl_certs_dir
  $apache_conf_dir = $::apache::params::conf_dir

  include profile::apache_webserver
  include profile::mysql

  # This breaks role/profile rules by including profile::php with resource-like
  # syntax, but short of duplicating lots of configuration in each nodes' hiera
  # settings, there doesn't seem to be an alternative to apply nextcloud-specific
  # php config.
  class { 'profile::php':
    ini_settings => {
      'PHP/upload_max_filesize' => '128M',
      'PHP/post_max_size'       => '128M',
      'PHP/max_input_time'      => '300',
      'PHP/memory_limit'        => '512M',
      'Date/date.timezone'      => 'America/Chicago',
    }
  }

  $ip_based = length($sites) ? {
    1       => true,
    default => false,
  }
  $ip = $ip_based ? {
    true    => $facts['ipaddress'],
    default => undef,
  }

  $sites.each |Hash $site, Bool $ip_based, String $ip| {
    ############################
    ### Apache configuration ###
    ############################
    $fqdn = $site['fqdn']
    $docroot = "/var/www/${fqdn}"

    file { "${ssl_certs_dir}/${fqdn}.crt":
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => "puppet:///modules/ssl_certs/${fqdn}.crt",
      notify => Service['httpd'],
    }
    file { "${ssl_certs_dir}/${fqdn}.key":
      owner     => 'root',
      group     => 'root',
      mode      => '0640',
      content   => $site['ssl_key'],
      show_diff => false,
      notify    => Service['httpd'],
    }

    $cilogon_config = "${apache_conf_dir}/${fqdn}_cilogon.conf"
    $oidc_client_id = $site['cilogon_client_id']
    $oidc_client_secret = $site['cilogon_client_secret']
    $oidc_crypto_passphrase = lookup('OIDCCryptoPassphrase')

    file { $cilogon_config:
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('website/nextcloud-cilogon.conf.erb'),
      notify  => Service['httpd'],
    }

    $fpm_port = $site['php_fpm_port']
    php::fpm::pool { $fqdn:
      listen => "127.0.0.1:${fpm_port}",
      user   => $site['php_fpm_user'],
      group  => $site['php_fpm_group'],
    }

    apache::vhost { $fqdn:
      servername          => $fqdn,
      ssl                 => true,
      port                => 443,
      ip_based            => $ip_based,
      ip                  => $ip,
      ssl_cert            => "${ssl_certs_dir}/${fqdn}.crt",
      ssl_key             => "${ssl_certs_dir}/${fqdn}.key",
      docroot             => $docroot,
      directories         => [
        {
          path             => $docroot,
          headers          => 'always set Strict-Transport-Security "max-age=15552000; includeSubDomains"',
          'options'        => ['+FollowSymLinks'],
          'allow_override' => ['All'],
        }
      ],
      proxy_pass_match    => [
        { 'path' => '^/(.*\.php(/.*)?)$', 'url' => "fcgi://127.0.0.1:${fpm_port}${docroot}/" }
      ],
      setenv              => [
        "HOME ${docroot}",
        "HTTP_HOME ${docroot}",
      ],
      block               => ['scm'],
      additional_includes => [$cilogon_config]
    }

    apache::vhost { "${fqdn}-http":
      servername      => $fqdn,
      ssl             => false,
      port            => 80,
      ip_based        => true,
      ip              => $ip,
      docroot         => '/var/www/nonssl_redirect_empty_docroot',
      redirect_status => 'permanent',
      redirect_dest   => "https://${fqdn}/",
    }

    ##############################
    ### Database Configuration ###
    ##############################
    mysql::db { $site['database_name']:
      user     => $site['database_name'],
      password => $site['database_password'],
      host     => 'localhost',
      grant    => ['ALL']
    }
  }
}
