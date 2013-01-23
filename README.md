# Librarian-puppet

## Introduction

Librarian-puppet is a bundler for your puppet infrastructure.  You can use
librarian-puppet to manage the puppet modules your infrastructure depends on.
It is based on [Librarian](https://github.com/applicationsonline/librarian), a
framework for writing bundlers, which are tools that resolve, fetch, install,
and isolate a project's dependencies.

Librarian-puppet manages your `modules/` directory for you based on your
`Puppetfile`.  Your `Puppetfile` becomes the authoritative source for what
modules you require and at what version, tag or branch.

Once using Librarian-puppet you should not modify the contents of your `modules`
directory.  The individual modules' repos should be updated, tagged with a new
release and the version bumped in your Puppetfile.

## The Puppetfile

Every Puppet repository that uses Librarian-puppet will have a file named
`Puppetfile` in the root directory of that repository.  The full specification
for which modules your puppet infrastructure repository  depends goes in here.

### Example Puppetfile

    forge "http://forge.puppetlabs.com"

    mod "puppetlabs/razor"
    mod "puppetlabs/ntp", "0.0.3"

    mod "apt",
      :git => "git://github.com/puppetlabs/puppetlabs-apt.git"

    mod "stdlib",
      :git => "git://github.com/puppetlabs/puppetlabs-stdlib.git"

*See [jenkins-appliance](https://github.com/aussielunix/jenkins-appliance) for
a puppet repo already setup to use librarian-puppet.*

### Puppetfile Breakdown

    forge "http://forge.puppetlabs.com"

This declares that we want to use the official Puppet Labs Forge as our default
source when pulling down modules.  If you run your own local forge, you may
want to change this.

    mod "puppetlabs/razor"

Pull in the latest version of the Puppet Labs Razor module from the default
source.

    mod "puppetlabs/ntp", "0.0.3"

Pull in version 0.0.3 of the Puppet Labs NTP module from the default source.

    mod "apt",
      :git => "git://github.com/puppetlabs/puppetlabs-apt.git"

Our puppet infrastructure repository depends on the `apt` module from the
Puppet Labs GitHub repos and checks out the `master` branch.

    mod "apt",
      :git => "git://github.com/puppetlabs/puppetlabs-apt.git",
      :ref => '0.0.3'

Our puppet infrastructure repository depends on the `apt` module from the
Puppet Labs GitHub repos and checks out a tag of `0.0.3`.

    mod "apt",
      :git => "git://github.com/puppetlabs/puppetlabs-apt.git",
      :ref => 'feature/master/dans_refactor'

Our puppet infrastructure repository depends on the `apt` module from the
Puppet Labs GitHub repos and checks out the `dans_refactor` branch.

When using a Git source, we do not have to use a `:ref =>`.
If we do not, then librarian-puppet will assume we meant the `master` branch.

If we use a `:ref =>`, we can use anything that Git will recognize as a ref.
This includes any branch name, tag name, SHA, or SHA unique prefix. If we use a
branch, we can later ask Librarian-puppet to update the module by fetching the
most recent version of the module from that same branch.

The Git source also supports a `:path =>` option. If we use the path option,
Librarian-puppet will navigate down into the Git repository and only use the
specified subdirectory. Some people have the habit of having a single repository
with many modules in it. If we need a module from such a repository, we can
use the `:path =>` option here to help Librarian-puppet drill down and find the
module subdirectory.

    mod "apt",
      :git => "git://github.com/fake/puppet-modules.git",
      :path => "modules/apt"

Our puppet infrastructure repository depends on the `apt` module, which we have
stored as a directory under our `puppet-modules` git repos.

## How to Use

Install librarian-puppet:

    $ gem install librarian-puppet

Prepare your puppet infrastructure repository:

    $ cd ~/path/to/puppet-inf-repos
    $ (git) rm -rf modules
    $ librarian-puppet init

Librarian-puppet takes over your `modules/` directory, and will always
reinstall (if missing) the modules listed the `Puppetfile.lock` into your
`modules/` directory, therefore you do not need your `modules/` directory to be
tracked in Git.

Librarian-puppet uses a `.tmp/` directory for tempfiles and caches. You should
not track this directory in Git.

Running `librarian-puppet init` will create a skeleton Puppetfile for you as
well as adding `tmp/` and `modules/` to your `.gitignore`.

    $ librarian-puppet install [--clean] [--verbose]

This command looks at each `mod` declaration and fetches the module from the
source specified.  This command writes the complete resolution into
`Puppetfile.lock` and then copies all of the fetched modules into your
`modules/` directory, overwriting whatever was there before.

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

 * Pull requests please.
 * Bonus points for feature branches.

## Reporting Issues

Bug reports to the github issue tracker please.
Please include:

 * Relevant `Puppetfile` and `Puppetfile.lock` files
 * Version of ruby, librarian-puppet
 * What distro
 * Please run the `librarian-puppet` commands in verbose mode by using the
  `--verbose` flag, and include the verbose output in the bug report as well.

## Changelog

### 0.9.0

 * Initial release

### 0.9.1

 * Proper error message when a module that is sourced from the forge does not
   exist.
 * Added support for annotated tags as git references.
 * `librarian-puppet init` adds `.tmp/` to gitignore instead of `tmp/`.
 * Fixed syntax error in the template Puppetfile created by `librarian-puppet
   init`.
 * Checks for `lib/puppet` as well as `manifests/` when checking if the git
   repository is a valid module.
 * When a user specifies `<foo>/<bar>` as the name of a module sources from a
   git repository, assume the module name is actually `<bar>`.
 * Fixed gem description and summary in gemspec.

## License
Please see the [LICENSE](https://github.com/rodjek/librarian-puppet/blob/master/LICENSE)
file.
