# == Class: profile::php
#
# Replaces the system PHP with a current version.
#
# === Parameters
#
# Document parameters here.
#
class profile::php {
  class { '::php::repo::redhat':
    yum_repo => 'remi_php71',
  }
  -> class { '::php::globals':
    php_version => '7.1',
  }
  -> class { '::php':
    manage_repos => true,
  }
}
