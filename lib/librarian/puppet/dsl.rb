require 'librarian/dsl'
require 'librarian/dsl/target'
require 'librarian/puppet/source'

module Librarian
  module Puppet
    class Dsl < Librarian::Dsl

      dependency :mod

      source :forge => Source::Forge
      source :git => Source::Git
      source :path => Source::Path
      source :github_tarball => Source::GitHubTarball

      # copied from Librarian::Dsl to use our own Receiver
      def run(specfile = nil, sources = [])
        specfile, sources = nil, specfile if specfile.kind_of?(Array) && sources.empty?

        Target.new(self).tap do |target|
          target.precache_sources(sources)
          debug_named_source_cache("Pre-Cached Sources", target)

          specfile ||= Proc.new if block_given?
          receiver = Receiver.new(target)
          receiver.run(specfile)

          debug_named_source_cache("Post-Cached Sources", target)
        end.to_spec
      end

      class Receiver < Librarian::Dsl::Receiver
        attr_reader :specfile

        # save the specfile and call librarian
        def run(specfile = nil)
          @specfile = specfile
          super
        end

        # implement the 'modulefile' syntax for Puppetfile
        def modulefile
          File.read(Pathname.new(specfile).parent.join('Modulefile')).lines.each do |line|
            regexp = /\s*dependency\s+('|")([^'"]+)\1\s*(?:,\s*('|")([^'"]+)\3)?/
            regexp =~ line && mod($2, $4)
          end
        end
      end
    end
  end
end
