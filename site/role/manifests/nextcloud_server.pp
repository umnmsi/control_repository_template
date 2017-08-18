# == Class: role::nextcloud_server
#
# NextCloud (https://nextcloud.com/) is a web application for file management, movement, and sharing.
# MSI offers deployments to U centers like the UMGC as a means to deliver instrument output to customers.
#
# === Parameters
#
# Document parameters here.
#
class role::nextcloud_server {
  include profile::nextcloud_server
  # In the future, we'll also have profiles for base_iops etc in here.
}
