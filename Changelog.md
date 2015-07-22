# Changelog

## From 2.x Librarian-Puppet requires Ruby >= 1.9, uses Puppet Forge API v3. For Ruby 1.8 use 1.x

### 2.2.1

 * [Issue #311](https://github.com/rodjek/librarian-puppet/issues/311) Omit versions with a deleted_at date

### 2.2.0

 * Add support for Puppet 4
 * [Issue #296](https://github.com/rodjek/librarian-puppet/issues/296) Uninitialized constant Puppet::ModuleTool::ModulefileReader using Modulefiles in Puppet 4. Ignore those dependencies

### 2.1.1

 * [Issue #302](https://github.com/rodjek/librarian-puppet/issues/302) Ensure path is not lost when default specfile is used
 * [Issue #294](https://github.com/rodjek/librarian-puppet/issues/294) Undefined variable calling Puppet version in old Puppet 2.x versions
 * [Issue #285](https://github.com/rodjek/librarian-puppet/issues/294) Update librarianp to allow overriding dependencies from multiple sources

### 2.1.0

 * Update librarian to use the new `exclusion` syntax
 * [Issue #282](https://github.com/rodjek/librarian-puppet/issues/282) Merge duplicated dependencies and warn the user, no more `Cannot bounce Puppetfile.lock!` errors
 * [Issue #217](https://github.com/rodjek/librarian-puppet/issues/217)[Issue #244](https://github.com/rodjek/librarian-puppet/issues/244) Use librarianp 0.4.0 that no longer uses recursion to avoid `stack level too deep` errors
 * [Issue #277](https://github.com/rodjek/librarian-puppet/issues/277) Warn when there are two dependencies with the same module name
 * Use `librarianp` gem instead of `librarian`, a fork with the needed improvements and fixes.

### 2.0.1

 * [Issue #272](https://github.com/rodjek/librarian-puppet/issues/272) Defined forge is not used when resolving dependencies
 * [Issue #150](https://github.com/rodjek/librarian-puppet/issues/150) Allow dependencies other than Puppet modules
 * [Issue #269](https://github.com/rodjek/librarian-puppet/issues/269) Better error message if metadata.json is bad
 * [Issue #264](https://github.com/rodjek/librarian-puppet/issues/264) Copying files can cause permission problems on Windows

### 2.0.0

 * Jump from 1.3.x to 2.x to leave 1.x for Ruby 1.8 compatibility
 * [Issue #254](https://github.com/rodjek/librarian-puppet/issues/254) Add a rsync option to prevent deleting directories
 * [Issue #261](https://github.com/rodjek/librarian-puppet/issues/261) Incorrect install directory is created if the organization name contains a dash
 * [Issue #255](https://github.com/rodjek/librarian-puppet/issues/255) Ignored forge URL when using API v3

### 1.5.0

 * Update librarian to use the new `exclusion` syntax
 * [Issue #282](https://github.com/rodjek/librarian-puppet/issues/282) Merge duplicated dependencies and warn the user, no more `Cannot bounce Puppetfile.lock!` errors
 * [Issue #217](https://github.com/rodjek/librarian-puppet/issues/217)[Issue #244](https://github.com/rodjek/librarian-puppet/issues/244) Use librarianp 0.4.0 that no longer uses recursion to avoid `stack level too deep` errors
 * [Issue #277](https://github.com/rodjek/librarian-puppet/issues/277) Warn when there are two dependencies with the same module name
 * Use `librarianp` gem instead of `librarian`, a fork with the needed improvements and fixes.

### 1.4.1

 * [Issue #272](https://github.com/rodjek/librarian-puppet/issues/272) Defined forge is not used when resolving dependencies
 * [Issue #150](https://github.com/rodjek/librarian-puppet/issues/150) Allow dependencies other than Puppet modules
 * [Issue #269](https://github.com/rodjek/librarian-puppet/issues/269) Better error message if metadata.json is bad
 * [Issue #264](https://github.com/rodjek/librarian-puppet/issues/264) Copying files can cause permission problems on Windows

### 1.4.0

 * Jump from 1.0.x to 1.4.x to keep Ruby 1.8 compatibility in the 1.x series
 * [Issue #254](https://github.com/rodjek/librarian-puppet/issues/254) Add a rsync option to prevent deleting directories
 * [Issue #261](https://github.com/rodjek/librarian-puppet/issues/261) Incorrect install directory is created if the organization name contains a dash

### 1.3.3

 * [Issue #250](https://github.com/rodjek/librarian-puppet/issues/250) Fix error when module has no dependencies in `metadata.json`

### 1.3.2

 * [Issue #246](https://github.com/rodjek/librarian-puppet/issues/246) Do not fail if modules have no `Modulefile` nor `metadata.json`

### 1.3.1

 * Version in dependencies with `metadata.json` is ignored

### 1.3.0

 * If no Puppetfile is present default to use the `metadata.json` or `Modulefile`
 * [Issue #235](https://github.com/rodjek/librarian-puppet/issues/235) Error when forge is not defined in `Puppetfile`
 * [Issue #243](https://github.com/rodjek/librarian-puppet/issues/243) Warn if `Modulefile` doesn't contain a version

### 1.2.0

 * Implement `metadata` syntax for `Puppetfile`
 * [Issue #220](https://github.com/rodjek/librarian-puppet/issues/220) Add support for metadata.json
 * [Issue #242](https://github.com/rodjek/librarian-puppet/issues/242) Get organization from name correctly if name has multiple dashes

### 1.1.3

 * [Issue #237](https://github.com/rodjek/librarian-puppet/issues/237) [Issue #238](https://github.com/rodjek/librarian-puppet/issues/238) Unable to use a custom v3 forge: add flags `--use-v1-api` and `--no-use-v1-api`
 * [Issue #239](https://github.com/rodjek/librarian-puppet/issues/239) GitHub tarball: add access_token correctly to url's which are already having query parameters
 * [Issue #234](https://github.com/rodjek/librarian-puppet/issues/234) Use organization-module instead of organization/module by default

### 1.1.2

 * [Issue #231](https://github.com/rodjek/librarian-puppet/issues/231) Only use the `GITHUB_API_TOKEN` if it's not empty
 * [Issue #233](https://github.com/rodjek/librarian-puppet/issues/233) Fix version regex to match e.g. 1.99.15
 * Can't pass the Puppet Forge v1 api url to clients using v3 (3.6.0+ and PE 3.2.0+)

### 1.1.1

 * [Issue #227](https://github.com/rodjek/librarian-puppet/issues/227) Fix Librarian::Puppet::VERSION undefined

### 1.1.0

 * [Issue #210](https://github.com/rodjek/librarian-puppet/issues/210) Use forgeapi.puppetlabs.com and API v3
   * Accesing the v3 API requires Ruby 1.9 due to the puppet_forge library used


### 1.0.10

 * [Issue #250](https://github.com/rodjek/librarian-puppet/issues/250) Fix error when module has no dependencies in `metadata.json`

### 1.0.9

 * [Issue #246](https://github.com/rodjek/librarian-puppet/issues/246) Do not fail if modules have no `Modulefile` nor `metadata.json`

### 1.0.8

 * Version in dependencies with `metadata.json` is ignored

### 1.0.7

 * If no Puppetfile is present default to use the `metadata.json` or `Modulefile`
 * [Issue #235](https://github.com/rodjek/librarian-puppet/issues/235) Error when forge is not defined in `Puppetfile`
 * [Issue #243](https://github.com/rodjek/librarian-puppet/issues/243) Warn if `Modulefile` doesn't contain a version


### 1.0.6

 * Implement `metadata` syntax for `Puppetfile`
 * [Issue #220](https://github.com/rodjek/librarian-puppet/issues/220) Add support for metadata.json
 * [Issue #242](https://github.com/rodjek/librarian-puppet/issues/242) Get organization from name correctly if name has multiple dashes

### 1.0.5

 * [Issue #237](https://github.com/rodjek/librarian-puppet/issues/237)[Issue #238](https://github.com/rodjek/librarian-puppet/issues/238) Unable to use a custom v3 forge: add flags `--use-v1-api` and `--no-use-v1-api`
 * [Issue #239](https://github.com/rodjek/librarian-puppet/issues/239) GitHub tarball: add access_token correctly to url's which are already having query parameters
 * [Issue #234](https://github.com/rodjek/librarian-puppet/issues/234) Use organization-module instead of organization/module by default

### 1.0.4

 * [Issue #231](https://github.com/rodjek/librarian-puppet/issues/231) Only use the `GITHUB_API_TOKEN` if it's not empty
 * [Issue #233](https://github.com/rodjek/librarian-puppet/issues/233) Fix version regex to match e.g. 1.99.15
 * Can't pass the Puppet Forge v1 api url to clients using v3 (3.6.0+ and PE 3.2.0+)

### 1.0.3

 * [Issue #223](https://github.com/rodjek/librarian-puppet/issues/223) `Cannot bounce Puppetfile.lock!` error when Forge modules contain duplicated dependencies

### 1.0.2

 * [Issue #211](https://github.com/rodjek/librarian-puppet/issues/211) Pass the PuppetLabs Forge API v3 endpoint to `puppet module` when running on Puppet >= 3.6.0
 * [Issue #198](https://github.com/rodjek/librarian-puppet/issues/198) Reduce the length of tmp dirs to avoid issues in windows
 * [Issue #206](https://github.com/rodjek/librarian-puppet/issues/206) githubtarball call for released versions does not consider pagination
 * [Issue #204](https://github.com/rodjek/librarian-puppet/issues/204) Fix regex to detect Forge API v3 url
 * [Issue #199](https://github.com/rodjek/librarian-puppet/issues/199) undefined method run! packaging a git source
 * Verify SSL certificates in github calls

### 1.0.1

 * [Issue #190](https://github.com/rodjek/librarian-puppet/issues/190) Pass the PuppetLabs Forge API v3 endpoint to `puppet module` when running on Puppet Enterprise >= 3.2
 * [Issue #196](https://github.com/rodjek/librarian-puppet/issues/196) Fix error in error handling when puppet is not installed

### 1.0.0

 * Remove deprecation warning for github_tarball sources, some people are actually using it

### 0.9.17

 * [Issue #193](https://github.com/rodjek/librarian-puppet/issues/193) Support Puppet 3.5.0

### 0.9.16

 * [Issue #181](https://github.com/rodjek/librarian-puppet/issues/181) Should use qualified module names for resolution to work correctly
 * Deprecate github_tarball sources
 * Reduce number of API calls for github_tarball sources

### 0.9.15

 * [Issue #187](https://github.com/rodjek/librarian-puppet/issues/187) Fixed parallel installation issues
 * [Issue #185](https://github.com/rodjek/librarian-puppet/issues/185) Sanitize the gem/bundler environment before spawning (ruby 1.9+)

### 0.9.14

 * [Issue #182](https://github.com/rodjek/librarian-puppet/issues/182) Sanitize the environment before spawning (ruby 1.9+)
 * [Issue #184](https://github.com/rodjek/librarian-puppet/issues/184) Support transitive dependencies in modules using :path
 * Git dependencies using modulefile syntax make librarian-puppet fail
 * [Issue #108](https://github.com/rodjek/librarian-puppet/issues/108) Don't fail on malformed Modulefile from a git dependency

### 0.9.13

 * [Issue #176](https://github.com/rodjek/librarian-puppet/issues/176) Upgrade to librarian 0.1.2
 * [Issue #179](https://github.com/rodjek/librarian-puppet/issues/179) Need to install extra gems just in case we are in ruby 1.8
 * [Issue #178](https://github.com/rodjek/librarian-puppet/issues/178) Print a meaningful message if puppet gem can't be loaded for :git sources

### 0.9.12

 * Remove extra dependencies from gem added when 0.9.11 was released under ruby 1.8

### 0.9.11

 * Add modulefile dsl to reuse Modulefile dependencies
 * Consider Puppetfile-dependencies recursively in git-source
 * Support changing tmp, cache and scratch paths
 * librarian-puppet package causes an infinite loop
 * Show a message if no versions are found for a module
 * Make download of tarballs more robust
 * Require open3_backport in ruby 1.8 and install if not present
 * Git dependencies in both Puppetfile and Modulefile cause a Cannot bounce Puppetfile.lock! error
 * Better sort of github tarball versions when there are mixed tags starting with and without 'v'
 * Fix error if a git module has a dependency without version
 * Fix git dependency with :path attribute
 * Cleaner output when no Puppetfile found
 * Reduce the number of API calls to the Forge
 * Don't sort versions as strings. Rely on the forge returning them ordered
 * Pass --module_repository to `puppet module install` to install from other forges
 * Cache forge responses and print an error if returns an invalid response
 * Add a User-Agent header to all requests to the GitHub API
 * Convert puppet version requirements to rubygems, pessimistic and ranges
 * Use librarian gem

### 0.9.10

 * Catch GitHub API rate limit exceeded
 * Make Librarian::Manifest Semver 2.0.0 compatible

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

### 0.9.0
 * Initial release
