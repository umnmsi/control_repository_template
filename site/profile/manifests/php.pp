# == Class: profile::php
#
# Replaces the system PHP with a current version.
#
# === Parameters
#
# Document parameters here.
#
class profile::php {
  class { '::php':
    manage_repos => true, # puppet-php currently uses remirepo.net for CentOS
  }
}
