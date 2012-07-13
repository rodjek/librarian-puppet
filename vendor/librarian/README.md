Librarian [![Build Status](https://secure.travis-ci.org/applicationsonline/librarian.png)](http://travis-ci.org/applicationsonline/librarian)
=========

Librarian is a framework for writing bundlers, which are tools that resolve,
fetch, install, and isolate a project's dependencies, in Ruby.

Librarian ships with Librarian-Chef, which is a bundler for your Chef-based
infrastructure repositories. In the future, Librarian-Chef will be a separate
project.

A bundler written with Librarian will expect you to provide a specfile listing
your project's declared dependencies, including any version constraints and
including the upstream sources for finding them. Librarian can resolve the spec,
write a lockfile listing the full resolution, fetch the resolved dependencies,
install them, and isolate them in your project.

A bundler written with Librarian will be similar in kind to [Bundler](http://gembundler.com),
the bundler for Ruby gems that many modern Rails applications use.

Librarian-Chef
---------------

Librarian-Chef is a tool that helps you manage the cookbooks that your chef-repo
depends on. Here are some more details.

Librarian-Chef is a bundler for infrastructure repositories using Chef. You can
use Librarian-Chef to resolve your infrastructure's cookbook dependencies, fetch
them, and install them into your infrastructure repository.

Librarian-Chef can resolve and fetch third-party, publicly-released cookbooks,
and install them into your infrastructure repository. It can also source
cookbooks directly from their own source control repositories.

Librarian-Chef can also deal with cookbooks you may actively be working on
outside your infrastructure repository. For example, it can deal with cookbooks
directly from their own private source control repositories, whether they are
remote or local to your machine, and it can deal with cookbooks released to and
hosted on a private cookbooks server.

Librarian-Chef is not primarily intended for dealing with the cookbooks you are
actively working on *within* your infrastructure repository. In such a case, you
can still use Librarian-Chef, but it is likely unnecessary.

Librarian-Chef *takes over* your `cookbooks/` directory and manages it for you
based on your `Cheffile`. Your `Cheffile` becomes the authoritative source for
the cookbooks your infrastructure repository depends on. You should not modify
the contents of your `cookbooks/` directory when using Librarian-Chef. If you
have cookbooks which are, rather than being separate projects, inherently part
of your infrastructure repository, then they should go in a separate directory,
like your `site-cookbooks/` directory, and you do not need to use Librarian-Chef
to manage them.

### The Cheffile

Every infrastruture repository that uses Librarian-Chef will have a file named
`Cheffile` in the root directory of that repository. The full specification for
which third-party, publicly-released cookbooks your infrastructure repository
depends will go here.

Here's an example `Cheffile`:

    site "http://community.opscode.com/api/v1"

    cookbook "ntp"
    cookbook "timezone", "0.0.1"

    cookbook "rvm",
      :git => "https://github.com/fnichol/chef-rvm",
      :ref => "v0.7.1"

    cookbook "cloudera",
      :path => "vendor/cookbooks/cloudera-cookbook"

Here's how it works:

We start off by declaring the *default source* for this `Cheffile`.

    site "http://community.opscode.com/api/v1"

This default source in this example is the Opscode Community Site API. This is
most likely what you will want for your default source. However, you can
certainly set up your own API-compatible HTTP endpoint if you want more control.

Any time we declare a cookbook dependency without also declaring a source for
that cookbook dependency, Librarian-Chef assumes we want it to look for that
cookbook in the default source.

Any time we declare a cookbook dependency that has subsidiary cookbook
dependencies of its own, Librarian-Chef assumes we want it to look for the
subsidiary cookbook dependencies in the default source.

    cookbook "ntp"

Our infrastructure repository depends on the `ntp` cookbook from the default
source. Any version of the `ntp` cookbook will fulfill our requirements.

    cookbook "timezone", "0.0.1"

Our infrastructure repository depends on the `timezone` cookbook from the
default source. But only version `0.0.1` of that cookbook will do.

    cookbook "rvm",
      :git => "https://github.com/fnichol/chef-rvm",
      :ref => "v0.7.1"

Our infrastructure repository depends on the `rvm` cookbook, but not the one
from the default source. Instead, the cookbook is to be fetched from the
specified Git repository and from the specified Git tag only.

When using a Git source, we do not have to use a `:ref =>`. If we do not,
then Librarian-Chef will assume we meant the `master` branch. (In the future,
this will be changed to whatever branch is the default branch according to
the Git remote, which may not be `master`.)

If we use a `:ref =>`, we can use anything that Git will recognize as a ref.
This includes any branch name, tag name, SHA, or SHA unique prefix. If we use a
branch, we can later ask Librarian-Chef to update the cookbook by fetching the
most recent version of the cookbook from that same branch.

The Git source also supports a `:path =>` option. If we use the path option,
Librarian-Chef will navigate down into the Git repository and only use the
specified subdirectory. Many people have the habit of having a single repository
with many cookbooks in it. If we need a cookbook from such a repository, we can
use the `:path =>` option here to help Librarian-Chef drill down and find the
cookbook subdirectory.

    cookbook "cloudera",
      :path => "vendor/cookbooks/cloudera-cookbook"

Our infrastructure repository depends on the `cloudera` cookbook, which we have
downloaded and copied into our repository. In this example, `vendor/cookbooks/`
is only for use with Librarian-Chef. This directory should not appear in the
`.chef/knife.rb`. Librarian-Chef will, instead, copy this cookbook from where
we vendored it in our repository into the `cookbooks/` directory for us.

The `:path =>` source won't be confused with the `:git =>` source's `:path =>`
option.

### How to Use

Install Librarian-Chef:

    $ gem install librarian

Prepare your infrastructure repository:

    $ cd ~/path/to/chef-repo
    $ git rm -r cookbooks
    $ echo /cookbooks >> .gitignore
    $ echo /tmp >> .gitignore

Librarian-Chef takes over your `cookbooks/` directory, and will always reinstall
the cookbooks listed the `Cheffile.lock` into your `cookbooks/` directory. Hence
you do not need your `cookbooks/` directory to be tracked in Git. If you
nevertheless want your `cookbooks/` directory to be tracked in Git, simple don't
`.gitignore` the directory.

If you are manually tracking/vendoring outside cookbooks within the repository,
put them in another directory such as `vendor/cookbooks/` and use the `:path =>`
source when declaring these cookbooks in your `Cheffile`. Most people will
typically not be manually tracking/vendoring outside cookbooks.

Librarian-Chef uses your `tmp/` directory for tempfiles and caches. You do not
need to track this directory in Git.

Make a Cheffile:

    $ librarian-chef init

This creates an empty `Cheffile` with the Opscode Community Site API as the
default source.

Add dependencies and their sources to the `Cheffile`:

    $ cat Cheffile
        site 'http://community.opscode.com/api/v1'
        cookbook 'ntp'
        cookbook 'timezone', '0.0.1'
        cookbook 'rvm',
          :git => 'https://github.com/fnichol/chef-rvm',
          :ref => 'v0.7.1'
        cookbook 'cloudera',
          :path => 'vendor/cookbooks/cloudera-cookbook'

This is the same `Cheffile` we saw above.

    $ librarian-chef install [--clean] [--verbose]

This command looks at each `cookbook` declaration and fetches the cookbook from
the source specified, or from the default source if none is provided.

Each cookbook is inspected, its dependencies are determined, and each dependency
is also fetched. For example, if you declare `cookbook 'nagios'`, which
depends on other cookbooks such as `'php'`, then those other cookbooks
including `'php'` will be fetched. This goes all the way down the chain of
dependencies.

This command writes the complete resolution into `Cheffile.lock`.

This command then copies all of the fetched cookbooks into your `cookbooks/`
directory, overwriting whatever was there before. You can then use `knife
cookbook upload -all` to upload the cookbooks to your chef-server, if you are
using the client-server model.

Check your `Cheffile` and `Cheffile.lock` into version control:

    $ git add Cheffile
    $ git add Cheffile.lock
    $ git commit -m "I want these particular versions of these particular cookbooks from these particular."

Make sure you check your `Cheffile.lock` into version control. This will ensure
dependencies do not need to be resolved every run, greatly reducing dependency
resolution time.

Get an overview of your `Cheffile.lock` with:

    $ librarian-chef show

Inspect the details of specific resolved dependencies with:

    $ librarian-chef show NAME1 [NAME2, ...]

Update your `Cheffile` with new/changed/removed constraints/sources/dependencies:

    $ cat Cheffile
        site 'http://community.opscode.com/api/v1'
        cookbook 'ntp'
        cookbook 'timezone', '0.0.1'
        cookbook 'rvm',
          :git => 'https://github.com/fnichol/chef-rvm',
          :ref => 'v0.7.1'
        cookbook 'monit' # new!
    $ git diff Cheffile
    $ librarian-chef install [--verbose]
    $ git diff Cheffile.lock
    $ git add Cheffile
    $ git add Cheffile.lock
    $ git commit -m "I also want these additional cookbooks."

Find out which dependencies are outdated and may be updated:

    $ librarian-chef outdated [--verbose]

Update the version of a dependency:

    $ librarian-chef update ntp timezone monit [--verbose]
    $ git diff Cheffile.lock
    $ git add Cheffile.lock
    $ git commit -m "I want updated versions of these cookbooks."

Push your changes to the git repository:

    $ git push origin master

Upload the cookbooks to your chef-server:

    $ knife cookbook upload --all

### Configuration

Configuration comes from three sources with the following highest-to-lowest
precedence:

* The local config (`./.librarian/chef/config`)
* The environment
* The global config (`~/.librarian/chef/config`)

You can inspect the final configuration with:

    $ librarian-chef config

You can find out where a particular key is set with:

    $ librarian-chef config KEY

You can set a key at the global level with:

    $ librarian-chef config KEY VALUE --global

And remove it with:

    $ librarian-chef config KEY --global --delete

You can set a key at the local level with:

    $ librarian-chef config KEY VALUE --local

And remove it with:

    $ librarian-chef config KEY --local --delete

You cannot set or delete environment-level config keys with the CLI.

Configuration set at either the global or local level will affect subsequent
invocations of `librarian-chef`. Configurations set at the environment level are
not saved and will not affect subsequent invocations of `librarian-chef`.

You can pass a config at the environment level by taking the original config key
and transforming it: replace hyphens (`-`) with underscores (`_`) and periods
(`.`) with doubled underscores (`__`), uppercase, and finally prefix with
`LIBRARIAN_CHEF_`. For example, to pass a config in the environment for the key
`part-one.part-two`, set the environment variable
`LIBRARIAN_CHEF_PART_ONE__PART_TWO`.

Configuration affects how various commands operate.

* The `path` config sets the cookbooks directory to install to. If a relative
  path, it is relative to the directory containing the `Cheffile`. The
  equivalent environment variable is `LIBRARIAN_CHEF_PATH`.

* The `install.strip-dot-git` config causes the `.git/` directory to be stripped
  out when installing cookbooks from a git source. This must be set to exactly
  "1" to cause this behavior. The equivalent environment variable is
  `LIBRARIAN_CHEF_INSTALL__STRIP_DOT_GIT`.

Configuration can be set by passing specific options to other commands.

* The `path` config can be set at the local level by passing the `--path` option
  to the `install` command. It can be unset at the local level by passing the
  `--no-path` option to the `install` command. Note that if this is set at the
  environment or global level then, even if `--no-path` is given as an option,
  the environment or global config will be used.

* The `install.strip-dot-git` config can be set at the local level by passing
  the `--strip-dot-git` option to the `install` command. It can be unset at the
  local level by passing the `--no-strip-dot-git` option.

### Knife Integration

You can integrate your `knife.rb` with Librarian-Chef.

Stick the following in your `knife.rb`:

    require 'librarian/chef/integration/knife'
    cookbook_path Librarian::Chef.install_path,
                  "/path/to/chef-repo/site-cookbooks"

In the above, do *not* to include the path to your `cookbooks/` directory. If
you have additional cookbooks directories in your chef-repo that you use for
vendored cookbooks (where you use the `:path =>` source in your `Cheffile`),
make sure *not* to include the paths to those additional cookbooks directories
either.

You still need to include your `site-cookbooks/` directory in the above list.

What this integration does is whenever you use any `knife` command, it will:

* Enforce that your `Cheffile` and `Cheffile.lock` are in sync
* Install the resolved cookbooks to a temporary directory
* Configure Knife to look in the temporary directory for the installed cookbooks
  and not in the normal `cookbooks/` directory.

When you use this integration, any changes you make to anything in the
`cookbooks/` directory will be ignored by Knife, because Knife won't look in
that directory for your cookbooks.

How to Contribute
-----------------

### Running the tests

    # Either
    $ rspec spec
    $ cucumber

    # Or
    $ rake

You will probably need some way to isolate gems. Librarian provides a `Gemfile`,
so if you want to use bundler, you can prepare the directory with the usual
`bundle install` and run each command prefixed with the usual `bundle exec`, as:

    $ bundle install
    $ bundle exec rspec spec
    $ bundle exec cucumber
    $ bundle exec rake

### Installing locally

    $ rake install

You should typically not need to install locally, if you are simply trying to
patch a bug and test the result on a test case. Instead of installing locally,
you are probably better served by:

    $ cd $PATH_TO_INFRASTRUCTURE_REPO
    $ $PATH_TO_LIBRARIAN_CHECKOUT/bin/librarian-chef install [--verbose]

### Reporting Issues

Please include relevant `Cheffile` and `Cheffile.lock` files. Please run the
`librarian-chef` commands in verbose mode by using the `--verbose` flag, and
include the verbose output in the bug report as well.

License
-------

Written by Jay Feldblum.

Copyright (c) 2011-2012 ApplicationsOnline, LLC.

Released under the terms of the MIT License. For further information, please see
the file `MIT-LICENSE`.
