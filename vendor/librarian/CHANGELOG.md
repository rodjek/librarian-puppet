# Change Log

## 0.0.24

* \#15. A remembered configuration system.

* \#16. Configure, and remember configuration for, chef install paths.

* \#38. Configure, and remember configuration for, stripping out `.git`
  directories from git-sources chef dependencies.

* \#76. Support git annotated tags.

* \#80. Ignore directories in the `PATH` named `git` when looking for the `git`
  bin.

* \#85. Provide a helpful message when running the `show` command without a
  lockfile present.

## 0.0.23

* \#41. Build gems with a built gemspec.

* \#67. Cache remote objects at the latest possible moments, and only when they
  are needed.

* \#68. Fix unpacking chef site-sourced packages on Windows by pivoting from a
  Librarian-managed scratch space, rather than pivoting from Windows' temp
  directory. There were unexplained problems with using the Windows temp
  directory in certain cases, possibly related to the temp directory and the
  Librarian cache directory being on different volumes.

* \#69. Fix invoking Librarian with git-sourced dependencies from git hooks by
  unsetting `GIT_DIR` around shelling out to git.

* Print general environment information when running with `--verbose`.

## 0.0.22

* Fix the `outdated` CLI command.

## 0.0.21

* \#64. Sources now raise when given unrecognized options in the specfile.

* A new `show` CLI command.

* Changed the `clean` CLI command no longer to delete the lockfile.

* Simplify the architecture of `Librarian::Manifest` vis-a-vis sources. It is no
  longer a base class for adapters to inherit. Now, sources expose a small
  interface, which `Librarian::Manifest` can call, for delay-loading attributes.

* The git source now resolves the `git` binary before `chdir`ing.

* Test on Rubinius.

## 0.0.20

* A command to print outdated dependencies.

## 0.0.19

* Fix breakage on 1.8.

## 0.0.18

* \#57. Include existing manifests' dependencies in resolution.

* Permit the update action even with a changed specfile.

## 0.0.17

* Use a pure-Ruby implementation of tar/gz. Helps with Windows support, since
  Windows boxes are less likely than *NIX boxes to have the `tar` executable.

* Fix an issue where the chef site source considers uncached manifests to be
  cached, and skips caching them, causing the install action to fail.

* Fail fast if the resolver produces an inconsistent resolution. It is a known
  issue that the resolver will sometimes (deterministically, not randomly)
  produce an inconsistent resolution when performing an update action (#57).
  Start debugging this by failing fast at this point and spitting out gobs of
  debug-level log details.

## 0.0.16

* Recache site-sourced dependency metadata per each run.

* \#46. Always install.

* \#53. Abstract versions & requirements from rubygems.

* Own the install path. Recreate it on each install.
    WARNING: If you have your own content in the install path, it will be deleted without mercy.

## 0.0.15

* Rewrite the README.

* \#44, \#49. Better updating of cached git sources without using local merges.

## 0.0.14

* \#39 Fixes a regression induced by using `git reset --hard SHA`.

## 0.0.13

* \#36 Fixes an issue where, if a dependency has a git source (the upstream), and the upstream is updated,
    then attempting to update that dependency in the local resolution would not update that dependency so
    long as that git source were cached (@databus23).

* More immediate detection of, and better error messages for, cases of blank dependency or manifest names
    or cases of names that are otherwise insensible, such as names that are untrimmed.

## 0.0.12

* Fixes an issue where, if a dependency has a git source with a ref, re-resolving may fail.

## 0.0.11

* Fix a regression where the cli command "version" failed.

## 0.0.10

This release focuses on refactoring some of the internals. There are no functional changes.

## 0.0.9

* \#11 Fixes a problem where, if the repo is in a path where a component has a space, attempting to resolve a
    site-sourced dependency fails.

## 0.0.8

* A `version` task.

* A change log.

* \#10 Fixes the problem with bouncing the lockfile when updating, when using a git source with the default ref.

## 0.0.7

* \#8 Add highline temporarily as a runtime dependency of `librarian` (@fnichol).
  When the project is split into `librarian` and `librarian-chef`, the `chef` runtime dependency will
    be moved to `librarian-chef`. If the project is further split into a knife plugin, the dependency
    will be moved there.

## 0.0.6

* \#7 Show a better error message when a cookbook is missing the required metadata file.

* Miscellaneous bugfixes.

## 0.0.5

* \#4 An `init` task for `librarian-chef`.
  This task creates a nearly-blank `Cheffile` with just the default Opscode Community Site source.

* Automatically create the `cookbooks` directory, if it's missing, when running the `install` task.

* \#3 Add `chef` temporarily as a runtime dependency of `librarian` (@fnichol).
  When the project is split into `librarian` and `librarian-chef`, the `chef` runtime dependency will
    be moved to `librarian-chef`.

## 0.0.4

* A simple knife integration.
  This integration allows you to specify a `librarian-chef`-managed tempdir as a `cookbook_path`.
  This is useful to force knife only to upload the exact cookbooks that `librarian-chef` knows
    about, rather than whatever happens to be found in the `cookbooks` directory.

## 0.0.3

* Miscellaneous bugfixes.

## 0.0.2

* An optional `:path` attribute for `:git` sources.
  This allows you to specify exactly where within a git repository a given cookbook is to be found.

* A full example of a Cheffile and its usage in the readme.

## 0.0.1

* Initial release.
