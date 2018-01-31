forge "http://forge.puppetlabs.com"

# Modules from the Puppet Forge, in alphabetical order.
mod 'darin-zypprepo',          '1.0.2'   # Latest on 7/26/17. Dependency of puppet-php.

# Maintained by Vox Pupuli (https://voxpupuli.org/)
mod 'puppet-archive',          '1.3.0'   # Latest on 7/26/17
mod 'puppet-php',
  :git => 'https://github.com/voxpupuli/puppet-php.git',
  :ref => '91a42b95fb9e9b093043853904441df3347a1db7'  # Latest on 8/17/17
mod 'puppet-staging',          '2.2.0'   # Latest on 7/27/17. Dependency of puppetlabs-mysql.

# Maintaned by Puppetlabs
mod 'puppetlabs-apache',       '2.0.0'   # Latest on 7/26/17
mod 'puppetlabs-apt',          '4.1.0'   # Latest on 7/26/17
mod 'puppetlabs-concat',       '4.0.1'   # Latest on 7/26/17
mod 'puppetlabs-inifile',      '2.0.0'   # Latest on 7/26/17
mod 'puppetlabs-mysql',        '3.11.0'  # Latest on 7/27/17
mod 'puppetlabs-stdlib',       '4.17.1'  # Latest on 7/26/17
mod 'puppetlabs-vcsrepo',      '2.2.0'   # Latest on 12/20/17
mod 'puppetlabs-firewall',     '1.12.0'	 # Latest on 1/25/18

# MSI "shared service" modules on UMN github.
# These will require an ssh key to be established for the user running r10k
# on the puppetserver, and that public key to be installed as a deployment key
# for these repositories on umn github.
#
# Branches-as-versioning model as proposed at
# https://docs.google.com/a/umn.edu/presentation/d/1OcMAZLw_tgkNvzEPaaFWiAEIryz9GIPsTS0pfCQYJ80/edit?usp=sharing

mod 'apache_msi',
  :git    => 'git@github.umn.edu:MSI-Puppet/module-apache_msi.git',
  :branch => '1.0'

mod 'nextcloud_msi',
  :git    => 'git@github.umn.edu:MSI-Puppet/module-nextcloud_msi.git',
  :branch => '1.0'

mod 'php_msi',
  :git    => 'git@github.umn.edu:MSI-Puppet/module-php_msi.git',
  :branch => '1.0'

mod 'panasas_msi',
  :git    => 'git@github.umn.edu:MSI-Puppet/module-panasas_msi.git',
  :branch => '1.0'

mod 'firewall_msi',
  :git    => 'git@github.umn.edu:MSI-Puppet/module-firewall_msi.git',
  :branch => '1.0'
