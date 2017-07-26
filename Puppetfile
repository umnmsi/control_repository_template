forge "http://forge.puppetlabs.com"

# Modules from the Puppet Forge
mod 'puppetlabs-stdlib',       '4.17.1'  # Latest on 7/26/17
mod 'puppetlabs-concat',       '4.0.1'   # Latest on 7/26/17
mod 'puppetlabs-apache',       '2.0.0'   # Latest on 7/26/17

# Modules from Git
# These will require an ssh key to be established for the user running r10k
# on the puppetserver, and that public key to be installed as a deployment key
# for these repositories on umn github.
#
# Branches-as-versioning model as proposed at
# https://docs.google.com/a/umn.edu/presentation/d/1OcMAZLw_tgkNvzEPaaFWiAEIryz9GIPsTS0pfCQYJ80/edit?usp=sharing

mod 'apache_msi',
  :git    => 'git@github.umn.edu:msi/ops_puppet_apache_msi.git',
  :branch => '1.0'
