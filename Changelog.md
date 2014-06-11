## Changelog

### 1.1.1

### 1.1.0

 * [Issue #210](https://github.com/rodjek/librarian-puppet/issues/210) Use forgeapi.puppetlabs.com and API v3
   * Accesing the v3 API requires Ruby 1.9 due to the puppet_forge library used

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
