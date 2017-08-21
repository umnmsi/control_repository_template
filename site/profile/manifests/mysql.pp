# == Class: profile::mysql
# Profile for mysql server.
#
# === Parameters
# [*root_password*]
#   An optional root password. If not specified, the default
#   from secure.eyaml will be used.
#
class profile::mysql(
  String $root_password = '',
) {
  if $root_password == '' {
    $_root_password = lookup('credentials_mysql::root_password')
  } else {
    $_root_password = $root_password
  }

  class { '::mysql::server':
    root_password           => $_root_password,
    remove_default_accounts => true,
  }
}
