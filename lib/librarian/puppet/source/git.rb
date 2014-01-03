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
          return vendor_checkout! if vendor_cached?

          if environment.local?
            raise Error, "Could not find a local copy of #{uri} at #{sha}."
          end

          super

          cache_in_vendor(repository.path) if environment.vendor?
        end

        def vendor_tgz
          environment.vendor_source + "#{sha}.tar.gz"
        end

        def vendor_cached?
          vendor_tgz.exist?
        end

        def vendor_checkout!
          repository.path.rmtree if repository.path.exist?
          repository.path.mkpath

          Dir.chdir(repository.path.to_s) do
            %x{tar xzf #{vendor_tgz}}
          end

          repository_cached!
        end

        def cache_in_vendor(tmp_path)
          Dir.chdir(tmp_path.to_s) do
            %x{git archive #{sha} | gzip > #{vendor_tgz}}
          end
        end

        def fetch_version(name, extra)
          cache!
          found_path = found_path(name)
          module_version
        end

        def fetch_dependencies(name, version, extra)
          dependencies = []

          if modulefile?
            metadata = ::Puppet::ModuleTool::Metadata.new

            ::Puppet::ModuleTool::ModulefileReader.evaluate(metadata, modulefile)

            metadata.dependencies.each do |dependency|
              name = dependency.instance_variable_get(:@full_module_name)
              version = dependency.instance_variable_get(:@version_requirement)
              gem_requirement = Requirement.new(version).gem_requirement
              dependencies.push Dependency.new(name, gem_requirement, forge_source)
            end
          end

          if specfile?
            spec = environment.dsl(Pathname(specfile))
            dependencies.concat spec.dependencies
          end

          dependencies
        end

        def forge_source
          Forge.from_lock_options(environment, :remote=>"http://forge.puppetlabs.com")
        end

        private

        # Naming this method 'version' causes an exception to be raised.
        def module_version
          return '0.0.1' unless modulefile?

          metadata  = ::Puppet::ModuleTool::Metadata.new
          ::Puppet::ModuleTool::ModulefileReader.evaluate(metadata, modulefile)

          metadata.version
        end

        def modulefile
          File.join(filesystem_path, 'Modulefile')
        end

        def modulefile?
          File.exists?(modulefile)
        end

        def specfile
          File.join(filesystem_path, environment.specfile_name)
        end

        def specfile?
          File.exists?(specfile)
        end

      end
    end
  end
end
