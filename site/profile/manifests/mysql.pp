# == Class: profile::mysql
# Profile for mysql server.
#
# === Parameters
# [*root_password*]
#   An optional root password. If not specified, the default
#   from secure.eyaml will be used.
# [*override_options*]
#   Allows you to tune MySQL settings supported by my.cnf.
#   See https://forge.puppet.com/puppetlabs/mysql/readme#customize-server-options.
#
class profile::mysql(
  String $root_password = '',
  Hash $override_options = { },
) {
  if $root_password == '' {
    $_root_password = lookup('credentials_mysql.root_password')
  } else {
    $_root_password = $root_password
  }

  class { '::mysql::server':
    root_password           => $_root_password,
    remove_default_accounts => true,
    override_options        => deep_merge({
        'mysqld' => {
          'max_allowed_packet' => '16M',
        },
      },
      $override_options
    ),
  }
}
