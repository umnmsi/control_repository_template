# == Class: profile::php
#
# Replaces the system PHP with a current version.
#
# === Parameters
#
# Document parameters here.
#
class profile::php {
  class { '::php::globals':
    php_version => '7.1',
  }
  -> yumrepo { 'remi-php71':
    # $releasever and $basearch are not puppet variables and are meaningful to yum.
    descr      => 'Remi\'s PHP 7.1 RPM repository for Enterprise Linux $releaesver - $basearch',
    mirrorlist => 'https://rpms.remirepo.net/enterprise/$releasever/php71/mirror',
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => 'https://rpms.remirepo.net/RPM-GPG-KEY-remi',
    priority   => 1,
  }
  -> class { '::php':
    manage_repos => false,
  }
}
