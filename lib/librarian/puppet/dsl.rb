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

module Librarian
  class Dsl
    class Receiver
      def modulefile
        File.read('Modulefile').lines.each do |line|
          regexp = /\s*dependency\s+('|")([^'"]+)\1\s*(?:,\s*('|")([^'"]+)\3)?/
          regexp =~ line && mod($2, $4)
        end
      end
    end
  end
end
