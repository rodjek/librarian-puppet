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
        include Librarian::Puppet::Util

        def cache!
          return vendor_checkout! if vendor_cached?

          if environment.local?
            raise Error, "Could not find a local copy of #{uri}#{" at #{sha}" unless sha.nil?}."
          end

          begin
            super
          rescue Librarian::Posix::CommandFailure => e
            raise Error, "Could not checkout #{uri}#{" at #{sha}" unless sha.nil?}: #{e}"
          end

          cache_in_vendor(repository.path) if environment.vendor?
        end

        private

        def vendor_tar
          environment.vendor_source.join("#{sha}.tar")
        end

        def vendor_tgz
          environment.vendor_source.join("#{sha}.tar.gz")
        end

        def vendor_cached?
          vendor_tgz.exist?
        end

        def vendor_checkout!
          repository.path.rmtree if repository.path.exist?
          repository.path.mkpath

          Librarian::Posix.run!(%W{tar xzf #{vendor_tgz}}, :chdir => repository.path.to_s)

          repository_cached!
        end

        def cache_in_vendor(tmp_path)
          Librarian::Posix.run!(%W{git archive -o #{vendor_tar} #{sha}}, :chdir => tmp_path.to_s)
          Librarian::Posix.run!(%W{gzip #{vendor_tar}}, :chdir => tmp_path.to_s)
        end

      end
    end
  end
end
