require 'librarian/cli/manifest_presenter'
module Librarian
  class Cli
    class ManifestPresenter

      def present_one(manifest, options = { })
        full = options[:detailed]

        if manifest.source.class == Librarian::Puppet::Source::Git
          sha = " #{manifest.source.sha[0..6]}"
        end
        say "#{manifest.name} (#{manifest.version}#{sha})" do
          if full
            say "source: #{manifest.source}"
            unless manifest.dependencies.empty?
              say "dependencies:" do
                manifest.dependencies.sort_by(&:name).each do |dependency|
                  say "#{dependency.name} (#{dependency.requirement})"
                end
              end
            end
          end
        end
      end
    end
  end
end
