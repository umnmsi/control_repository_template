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
class profile::php (
  String $fpm_socket = '/var/run/php7-fpm.sock'
) {

  if Class['apache'] {
    $has_apache = true
  } else {
    $has_apache = false
  }

  $fpm_service_ensure = $has_apache ? {
    true  => 'running',
    false => 'stopped',
  }

  $fpm_pools = $has_apache ? {
    true => {
      www => {'listen' => $fpm_socket }
    },
    false => { },
  }

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
    fpm_service_enable => $has_apache,
    fpm_service_ensure => $fpm_service_ensure,
    fpm_pools          => $fpm_pools,
  }

  class { '::php_msi::extensions':
    require => Class['profile::php'],
  }

  if $has_apache {
    include apache::mod::proxy_fcgi
    file { $fpm_socket:
      ensure  => present,
      owner   => $::apache::user,
      mode    => '0700',
      require => Class['php'],
    }
  }
}
