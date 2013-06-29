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

        # Naming this method 'version' causes an exception to be raised.
        def module_version
          return '0.0.1' unless modulefile?

          metadata  = ::Puppet::ModuleTool::Metadata.new
          ::Puppet::ModuleTool::ModulefileReader.evaluate(metadata, modulefile)

          metadata.version
        end

        def dependencies
          return {} unless modulefile? or puppetfile?
          
          if modulefile?
            metadata = ::Puppet::ModuleTool::Metadata.new

            ::Puppet::ModuleTool::ModulefileReader.evaluate(metadata, modulefile)

            metadata.dependencies.map do |dependency|
              name = dependency.instance_variable_get(:@full_module_name)
              version = dependency.instance_variable_get(:@version_requirement)
              v = Librarian::Puppet::Requirement.new(version).gem_requirement
              Dependency.new(name, v, forge_source)
            end
          elsif puppetfile?
            Librarian::Puppet::Environment.new(:project_path => path).specfile.read.dependencies
          end
        end

        def modulefile
          File.join(path, 'Modulefile')
        end

        def modulefile?
          File.exists?(modulefile)
        end
        
        def puppetfile?
          File.exists?(File.join(path, 'Puppetfile'))
        end

        def forge_source
          Librarian::Puppet::Source::Forge.from_lock_options(environment, :remote=>"http://forge.puppetlabs.com")
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
          v = repository.module_version
          v = v.gsub("-",".") # fix for some invalid versions like 1.0.0-rc1

          # if still not valid, use some default version
          unless Gem::Version.correct? v
            debug { "Ignoring invalid version '#{v}' for module #{name}, using 0.0.1" }
            v = '0.0.1'
          end
          v
        end

        def fetch_dependencies(name, version, extra)
          repository.dependencies
        end

      end
    end
  end
end
