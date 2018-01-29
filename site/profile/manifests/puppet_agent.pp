# == Class: profile::puppet_agent
#
# Manages upgrading and configuration of puppet agents at MSI, primarily using
# puppetlabs/puppet_agent.
#
# === Parameters
#
# Document parameters here.
#
class profile::puppet_agent {
  include ::puppet_agent # puppetlabs/puppet_agent
}
