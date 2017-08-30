# == Class: profile::nextcloud_server
#
# Profile for NextCloud server instances.
#
# === Parameters
#
# [*fqdn*]
#   The fully qualified domain name of this NextCloud.
# [*ip*]
#   The IP address where this NextCloud will be hosted.
#
class profile::nextcloud_server (
  String $fqdn = $trusted['certname'],
  String $ip   = $facts['ipaddress'],
) {
  ############################
  ### Apache configuration ###
  ############################
  include profile::apache_webserver

  # This breaks role/profile rules by including profile::php with resource-like
  # syntax, but short of duplicating lots of configuraiton in each nodes' hiera
  # settings, there doesn't seem to be an alternative to apply nextcloud-specific
  # php config.
  class { 'profile::php':
    ini_settings => {
      'PHP/upload_max_filesize' => '32M',
      'PHP/post_max_size'       => '32M',
      'PHP/max_input_time'      => '300',
      'PHP/memory_limit'        => '64M',
      'Date/date.timezone'      => 'America/Chicago',
    }
  }

  # If we wanted to run multiple sites per physical node, resources below
  # here could probably be added to a lambda over an array of hashes providing
  # fqdn and running user/group. We'd mostly just want to add a php::fpm::pool
  # resource for each.

  $docroot = "/var/www/${fqdn}"
  $ssl_certs_dir = $::apache::params::ssl_certs_dir

  file { "${ssl_certs_dir}/${fqdn}.crt":
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "puppet:///modules/ssl_certs/${fqdn}.crt",
    notify => Service['httpd'],
  }
  $website_ssl_keys = lookup('website_ssl_keys')
  file { "${ssl_certs_dir}/${fqdn}.key":
    owner     => 'root',
    group     => 'root',
    mode      => '0640',
    content   => $website_ssl_keys[$fqdn],
    show_diff => false,
    notify    => Service['httpd'],
  }

  php::fpm::pool { $fqdn:
    listen => '127.0.0.1:9000',
    user   => $::apache::user,
    group  => $::apache::group,
  }

  apache::vhost { $fqdn:
    servername       => $fqdn,
    ssl              => true,
    port             => 443,
    ip_based         => true,
    ip               => $ip,
    ssl_cert         => "${ssl_certs_dir}/${fqdn}.crt",
    ssl_key          => "${ssl_certs_dir}/${fqdn}.key",
    docroot          => $docroot,
    directories      => [
      {
        path             => $docroot,
        headers          => 'always set Strict-Transport-Security "max-age=15552000; includeSubDomains"',
        'options'        => ['+FollowSymLinks'],
        'allow_override' => ['All'],
      }
    ],
    proxy_pass_match => [
      { 'path' => '^/(.*\.php(/.*)?)$', 'url' => "fcgi://127.0.0.1:9000${docroot}/" }
    ],
    setenv           => [
      "HOME ${docroot}",
      "HTTP_HOME ${docroot}",
    ],
    block            => ['scm'],
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
  include profile::mysql

  mysql::db { 'nextcloud':
    user     => 'nextcloud',
    password => '*33D8B521314C648A6D5125CF472C3F43C317B339', # This is a hash
    host     => 'localhost',
    grant    => ['ALL']
  }
}
