# Librarian-puppet

*currently in beta and only supports retrieving modules from git*

## Introduction

Librarian-puppet is a bundler for your puppet infrastructure.  
You can use Librarian-puppet to manage the puppet modules your infrastructure depends on.  
It is based on [Librarian](https://github.com/applicationsonline/librarian), a framework for writing bundlers, which are tools that resolve,  
fetch, install, and isolate a project's dependencies.  

Librarian-puppet manages your `modules/` directory for you based on your `Puppetfile`  
Your `Puppetfile` becomes the authoritative source for what modules you require and at what  
version, tag or branch.  
Once using Librarian-puppet you should not modify the contents of any of your `modules`  
The individual modules' repos should be updated, tagged with a new release and the version  
bumped in your Puppetfile.  

## The Puppetfile

Every Puppet repository that uses Librarian-puppet will have a file named  `Puppetfile`  
in the root directory of that repository.  
The full specification for which modules your puppet infrastructure repository  depends goes in here.  

### Example Puppetfile

    mod "apt",
      :git => "git://github.com/puppetlabs/puppetlabs-apt.git"

    mod "stdlib",
      :git => "git://github.com/puppetlabs/puppetlabs-stdlib.git"

*See [jenkins-appliance](https://github.com/aussielunix/jenkins-appliance) for a puppet repos already setup to test librarian-puppet out.*


### Puppetfile Breakdown

    mod "apt",
      :git => "git://github.com/puppetlabs/puppetlabs-apt.git"

Our puppet infrastructure repository depends on the `apt` module from the puppetlabs  
github repos and checks out the `master` branch.  

    mod "apt",
      :git => "git://github.com/puppetlabs/puppetlabs-apt.git"
      :ref => '0.0.3'

Our puppet infrastructure repository depends on the `apt` module from the puppetlabs  
github repos and checks out a tag of `0.0.3`.  

    mod "apt",
      :git => "git://github.com/puppetlabs/puppetlabs-apt.git"
      :ref => 'feature/master/dans_refactor'

Our puppet infrastructure repository depends on the `apt` module from the puppetlabs  
github repos and checks out the `dans_refactor` branch.  

When using a Git source, we do not have to use a `:ref =>`.  
If we do not, then Librarian-puppet will assume we meant the `master` branch.  

If we use a `:ref =>`, we can use anything that Git will recognize as a ref.  
This includes any branch name, tag name, SHA, or SHA unique prefix. If we use a  
branch, we can later ask Librarian-pupet to update the modulek by fetching the  
most recent version of the module from that same branch.  

The Git source also supports a `:path =>` option. If we use the path option,  
Librarian-puppet will navigate down into the Git repository and only use the  
specified subdirectory. Some people have the habit of having a single repository  
with many modules in it. If we need a module from such a repository, we can  
use the `:path =>` option here to help Librarian-puppet drill down and find the  
module subdirectory.  

    mod "apt",
      :git => "git://github.com/fake/puppet-modules.git"
      :path => "modules/apt"

Our puppet infrastructure repository depends on the `apt` module, which we have stored  
as a directory under our `puppet-modules` git repos.  

## How to Use

Install Librarian-puppet:

    $ gem install --pre librarian-puppet

Prepare your puppet infrastructure repository:

    $ cd ~/path/to/puppet-inf-repos
    $ (git) rm -rf modules
    $ echo modules >> .gitignore
    $ echo tmp >> .gitignore

Librarian-puppet takes over your `modules/` directory, and will always  
reinstall (if missing) the modules listed the `Puppetfile.lock` into your `modules/` directory.  
Therefore you do not need your `modules/` directory to be tracked in Git.  

Librarian-puppet uses your `tmp/` directory for tempfiles and caches. You should not  
track this directory in Git.  

Make a Puppetfile:

    $ librarian-puppet init

This creates an empty `Puppetfile` with some example entries.  

    $ librarian-puppet install [--clean] [--verbose]

This command looks at each `mod` declaration and fetches the module from  
the source specified.  
This command writes the complete resolution into `Puppetfile.lock`.  
This command then copies all of the fetched modules into your `modules/`  
directory, overwriting whatever was there before.  

Get an overview of your `Puppetfile.lock` with:  

    $ librarian-puppet show

Inspect the details of specific resolved dependencies with:  

    $ librarian-puppet show NAME1 [NAME2, ...]

Find out which dependencies are outdated and may be updated:  

    $ librarian-puppet outdated [--verbose]

Update the version of a dependency:  

    $ librarian-puppet update apt [--verbose]
    $ git diff Puppetfile.lock
    $ git add Puppetfile.lock
    $ git commit -m "bumped the version of apt up to 0.0.4."

## How to Contribute

Pull requests please.  
Bonus points for feature branches.  

## Reporting Issues

Bug reports to the github issue tracker please.  
Please include:  

* relevant `Puppetfile` and `Puppetfile.lock` files.
* version of ruby, librarian-puppet
* What distro
* Please run the `librarian-puppet` commands in verbose mode by using the `--verbose` flag, and
  include the verbose output in the bug report as well.

## License

Written by Time Sharpe  
Copyright (c) 2012  
Released under the terms of the MIT License.  
For further information, please see [LICENSE](https://github.com/rodjek/librarian-puppet/blob/master/LICENSE)

