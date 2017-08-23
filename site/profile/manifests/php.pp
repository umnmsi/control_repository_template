# == Class: profile::php
#
# Replaces the system PHP with a current version.
# Currently only works on CentOS, because voxpupuli/php doesn't
# quite manage repositories correctly and the PR merge rate was low enough
# that I didn't want to attempt a mainline fix, so instead I just disabled
# repo management and threw in some enterprise-linux only code to add
# remi-php71.
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
    descr      => 'Remi\'s PHP 7.1 RPM repository for Enterprise Linux $releasever - $basearch',
    mirrorlist => 'https://rpms.remirepo.net/enterprise/$releasever/php71/mirror',
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => 'https://rpms.remirepo.net/RPM-GPG-KEY-remi',
    priority   => 1,
  }
  -> class { '::php':
    manage_repos       => false,
    fpm_service_enable => true,
    fpm_service_ensure => 'running',
    fpm_pools          => { 'listen' => '/var/run/php7-fpm.sock' },
  }

  class { '::php_msi::extensions':
    require => Class['profile::php'],
  }
}
