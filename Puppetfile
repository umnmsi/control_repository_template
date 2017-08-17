forge "http://forge.puppetlabs.com"

# Modules from the Puppet Forge, in alphabetical order.
mod 'darin-zypprepo',          '1.0.2'   # Latest on 7/26/17. Dependency of puppet-php.

# Maintained by Vox Pupuli (https://voxpupuli.org/)
mod 'puppet-archive',          '1.3.0'   # Latest on 7/26/17
mod 'puppet-php',
  :git => 'https://github.com/voxpupuli/puppet-php.git',
  :ref => '7429e50260399e6cc7e1d2af5eb540834e306b5c'  # Latest on 7/26/17
mod 'puppet-staging',          '2.2.0'   # Latest on 7/27/17. Dependency of puppetlabs-mysql.

# Maintaned by Puppetlabs
mod 'puppetlabs-apache',       '2.0.0'   # Latest on 7/26/17
mod 'puppetlabs-apt',          '4.1.0'   # Latest on 7/26/17
mod 'puppetlabs-concat',       '4.0.1'   # Latest on 7/26/17
mod 'puppetlabs-inifile',      '2.0.0'   # Latest on 7/26/17
mod 'puppetlabs-mysql',        '3.11.0'  # Latest on 7/27/17
mod 'puppetlabs-stdlib',       '4.17.1'  # Latest on 7/26/17

# MSI "shared service" modules on UMN github.
# These will require an ssh key to be established for the user running r10k
# on the puppetserver, and that public key to be installed as a deployment key
# for these repositories on umn github.
#
# Branches-as-versioning model as proposed at
# https://docs.google.com/a/umn.edu/presentation/d/1OcMAZLw_tgkNvzEPaaFWiAEIryz9GIPsTS0pfCQYJ80/edit?usp=sharing

mod 'apache_msi',
  :git    => 'git@github.umn.edu:msi/ops_puppet_apache_msi.git',
  :branch => '1.0'
