require 'librarian/source/git'
require 'librarian/puppet/source/local'

module Librarian
  module Source
    class Git
      class Repository
        def hash_from(remote, reference)
          branch_names = remote_branch_names[remote]
          if branch_names.include?(reference)
            reference = "#{remote}/#{reference}"
          end

          command = %W(rev-parse #{reference}^{commit} --quiet)
          run!(command, :chdir => true).strip
        end
      end
    end
  end

  module Puppet
    module Source
      class Git < Librarian::Source::Git
        include Local

        def cache!
          super

          cache_in_vendor(repository.path) if environment.vendor?
        end

        def cache_in_vendor(tmp_path)
          output = environment.vendor_source + "#{sha}.tar.gz"

          return if output.exist?

          Dir.chdir(tmp_path.to_s) do
            %x{git archive #{sha} | gzip > #{output}}
          end
        end

      end
    end
  end
end
