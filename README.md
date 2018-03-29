MSI Puppet Control Repository Template
======================================

This is probably a good starting point for creating new MSI control
repositories. It was based on the [starter control repo from puppetlabs](https://github.com/puppetlabs/control-repo),
but adds MSI-specific things:
  * A `hiera.yaml` that includes MSI's `shared_hieradata` and is preconfigured for eyaml.
  * A `Puppetfile` that includes the `baseline_config_msi` module and its dependencies.  
    You may want to update the Puppetforge modules to their latest versions.
  * Nearly empty `role` and `profile` modules, with module-level hiera stubs for the
    `profile` module.
  * A default `CODEOWNERS` file that you can configure your GitHub repository to use
    in enforcing change policies.
    
When setting up a new control repository, you'll also want to modify the
r10k.yaml and envlink.yaml files in the [r10k_config repo](https://github.umn.edu/MSI-Puppet/r10k_config)
so that the deployment machinery knows how to deploy your new control repository.