# == Class: role::puppet_server
#
# Role for puppet server nodes (compile masters, CA, or Master of Masters)
#
# === Parameters
#
# Document parameters here.
#
class role::puppet_server {
  include profile::puppet_server
  # In the future, we'll also have profiles for base_iops etc in here.
}
