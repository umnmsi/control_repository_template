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
  # Include further profiles and classes
  include profile::apache_webserver
  include profile::mysql

  # This breaks role/profile rules by including profile::php with resource-like
  # syntax, but short of duplicating lots of configuration in each nodes' hiera
  # settings, there doesn't seem to be an alternative to apply nextcloud-specific
  # php config.
  class { 'profile::php':
    ini_settings => {
      'PHP/upload_max_filesize'                 => '16G',
      'PHP/post_max_size'                       => '16G',
      'PHP/max_input_time'                      => '600',
      'PHP/memory_limit'                        => '16G',
      'opcache/opcache.enable'                  => 1,
      'opcache/opcache.enable_cli'              => 1,
      'opcache/opcache.interned_strings_buffer' => 8,
      'opcache/opcache.max_accelerated_files'   => 10000,
      'opcache/opcache.memory_consumption'      => 128,
      'opcache/opcache.save_comments'           => 1,
      'opcache/opcache.revalidate_freq'         => 1,
      'Date/date.timezone'                      => 'America/Chicago',
    }
  }

  include apache_msi::mod::auth_openidc

  file { '/data':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Set variables
  $ssl_certs_dir = $::apache::params::ssl_certs_dir
  $apache_conf_dir = $::apache::params::conf_dir

  # Define a vhost and associated resources for each NextCloud instance.
  $sites.each |Hash $site| {
    ############################
    ### Apache configuration ###
    ############################
    $fqdn = $site['fqdn']
    if $site['ip'] {
      $ip = $site['ip']
    } else {
      $ip = $facts['ipaddress']
    }
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

    # Force there to be an explicit opting out of CILogon in the yaml, if it is not used.
    $cilogon_config_content = $site['no_cilogon_auth'] ? {
      true    => '# CILogon unimplemented on this site',
      default => template('website/nextcloud-cilogon.conf.erb'),
    }

    file { $cilogon_config:
      owner     => 'root',
      group     => 'root',
      mode      => '0600',
      content   => $cilogon_config_content,
      show_diff => false, # CILogon secret is embedded within
      require   => Class['apache'],
      notify    => Service['httpd'],
    }

    ## TCP socket approach ##
    $fpm_port = $site['php_fpm_port']
    php::fpm::pool { $fqdn:
      listen => "127.0.0.1:${fpm_port}",
      user   => $site['php_fpm_user'],
      group  => $site['php_fpm_group'],
    }

    ## Unix socket approach ##
    # php::fpm::pool { $fqdn:
    #  listen       => "/var/run/php-${fqdn}.sock",
    #  user         => $site['php_fpm_user'],
    #  group        => $site['php_fpm_group'],
    #  listen_owner => $::apache::user,
    # }

    $custom_fragment = @("ENDDOC")
    <FilesMatch .+\.php$>
      SetHandler "proxy:fcgi://localhost:${fpm_port}"
    </FilesMatch>
    ProxyTimeout 21600
    | ENDDOC

    apache::vhost { $fqdn:
      servername          => $fqdn,
      ssl                 => true,
      port                => 443,
      ip_based            => true, # Always doing IP-based in case webDAV clients don't grok SNI.
      ip                  => $ip,
      ssl_cert            => "${ssl_certs_dir}/${fqdn}.crt",
      ssl_key             => "${ssl_certs_dir}/${fqdn}.key",
      docroot             => $docroot,
      docroot_owner       => 'drupal',
      directories         => [
        {
          path             => $docroot,
          headers          => 'always set Strict-Transport-Security "max-age=15552000; includeSubDomains"',
          'options'        => ['+FollowSymLinks'],
          'allow_override' => ['All'],
        }
      ],
      proxy_pass_match    => [
        # { 'path' => '^/(.*\.php(/.*)?)$', 'url' => "fcgi://127.0.0.1:${fpm_port}${docroot}/" }
        # { 'path' => '^/(.*\.php(/.*)?)$', 'url' => "unix:/var/run/php-${fqdn}.sock|fcgi://${fqdn}${docroot}/" }
      ],
      custom_fragment     => $custom_fragment,
      setenv              => [
        "HOME ${docroot}",
        "HTTP_HOME ${docroot}",
      ],
      setenvif            => [
        'Authorization "(.*)" HTTP_AUTHORIZATION=$1',
        # Because https://stackoverflow.com/questions/17018586/apache-2-4-php-fpm-and-authorization-headers
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

    ###############################
    ### Docroot contents - code ###
    ###############################
    vcsrepo { $docroot:
      ensure   => latest,
      revision => $site['git_revision'],
      provider => git,
      source   => 'git://msi-githubuser@github.umn.edu:msi/nextcloud.git',
      user     => 'drupal',
      require  => Apache::Vhost[$fqdn],
      notify   => Exec["nextcloud db upgrade for ${fqdn}"],
    }

    # This command knows how to check and do nothing when the db schema is already
    # fully upgraded, so it is harmless to run after code changes that don't require
    # a db upgrade.
    # TODO: test what this does on first deployment, before db is installed.
    exec { "nextcloud db upgrade for ${fqdn}":
      user        => $site['php_fpm_user'],
      command     => "/usr/bin/env php ${docroot}/occ upgrade --no-interaction",
      refreshonly => true,
      require     => Mysql::Db[$site['database_name']],
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

    ############################################
    ### NextCloud background processing cron ###
    ############################################
    cron { "NextCloud ${fqdn}":
      command => "/bin/php -f ${docroot}/cron.php",
      user    => $site['php_fpm_user'],
      minute  => '*/10',
    }

    ######################
    ### Data directory ###
    ######################
    file { "/data/${fqdn}":
      ensure => 'directory',
      owner  => $site['php_fpm_user'],
      group  => 'drupal',
      mode   => '0770',
    }
  }
}
