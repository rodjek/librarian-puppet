require 'librarian/dsl'
require 'librarian/puppet/source'

module Librarian
  module Puppet
    class Dsl < Librarian::Dsl

      dependency :mod

      source :forge => Source::Forge
      source :git => Source::Git
      source :path => Source::Path
      source :github_tarball => Source::GitHubTarball
    end
  end
end
