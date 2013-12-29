## Changelog

### 0.9.11
 * Better sort of githib tarball versions when there are mixed tags starting with and without 'v'
 * Add modulefile dsl to reuse Modulefile dependencies
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
 * Consider Puppetfile-dependencies recursively in git-source

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
