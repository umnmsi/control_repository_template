# == Class: profile::php
#
# Replaces the system PHP with a current version.
#
# === Parameters
#
# Document parameters here.
#
class profile::php (
  $php_version = '7.1.7'
) {
  class { '::php::globals':
    php_version => $php_version
  }
  -> class { '::php':
    manage_repos => true, # puppet-php currently uses remirepo.net for CentOS
  }
}
