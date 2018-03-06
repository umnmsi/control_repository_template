class profile::base_iops {
  # Default repositories. Computed based on information we already have
  # rather than reading from hiera per best practice.
  case $facts['os']['name'] {
    'CentOS': {
      $default_repos = ['base', 'updates', 'epel']
    }
    default: {
      $default_repos = []
    }
  }

  $default_repos.each |$repo| {
    pax::repo($repo)
  }
}
