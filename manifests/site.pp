## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# Disable filebucket by default for all File resources:
#https://docs.puppet.com/pe/2015.3/release_notes.html#filebucket-resource-no-longer-created-by-default
File { backup => false }

# Our puppet manifests are generally written for and require puppet 4.10.
# Although puppet 3 agents are fairly good at following a puppet 4 server's
# directions, they don't always provide structured facts, for example, which
# our manifests assume are available.
# To minimize risk of overall catalog compilation failure when bringing up a
# new node, only give it the bare minimum catalog required to upgrade to puppet
# 4 if it is running puppet 3. This bare-minimum catalog must be kept compliant
# with default puppet 3 agent settings.
# We'll apply its full catalog on the next go-round.
if ($puppetversion =~ /^3\./) {
  notify { 'This is Puppet 3, but the catalog for this node may require Puppet 4. This alternate catalog will only upgrade the agent.': }
  include puppet_agent_msi::profile
} else {
  # Make sure baseline_config_msi::profile and its children are evaluated first;
  # this allows hiera-included roles/classes to safely use out-of-scope variables
  # declared in baseline_config_msi::profile.
  # Retain the ability to exclude baseline_config_msi::profile through hiera.
  $additional_classes = lookup('additional_classes', Array[String])
  if (member($additional_classes, 'baseline_config_msi::profile')) {
    include baseline_config_msi::profile
  }

  # Nodes not properly classified to a particular environment just get baseline_config_msi::profile
  # to ensure classification gets done.
  if (baseline_config_msi::environment_type() != 'misclassified') {
    if (defined('$primary_role')) {
      include("role::${primary_role}")
    }
    include($additional_classes)
  }
}

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default {
  # This is where you can declare classes for all nodes.
  # Assigning classes through hiera is preferred, see the 'classes' key of
  # hieradata/common.yaml in this repository.
  #
  # Example:
  #   class { 'my_class': }
}
