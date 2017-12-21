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
      'PHP/max_input_time'                      => '1200',
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

  file { '/var/nextcloud-tmp':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Define a vhost and associated resources for each NextCloud instance.
  $sites.each |Hash $site| {
    nextcloud_msi::instance { $site['fqdn']:
      site => $site,
    }
  }
}
