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
          return {} unless modulefile?

          metadata = ::Puppet::ModuleTool::Metadata.new

          ::Puppet::ModuleTool::ModulefileReader.evaluate(metadata, modulefile)

          metadata.dependencies.inject({}) do |h, dependency|
            name = dependency.instance_variable_get(:@full_module_name)
            version = dependency.instance_variable_get(:@version_requirement)
            h.update(name => version)
          end
        end

        def modulefile
          File.join(path, 'Modulefile')
        end

        def modulefile?
          File.exists?(modulefile)
        end
      end
    end
  end

  module Puppet
    module Source
      class Git < Librarian::Source::Git
        include Local

        def fetch_version(name, extra)
          cache!
          found_path = found_path(name)
          repository.module_version
        end

        def fetch_dependencies(name, version, extra)
          repository.dependencies.map do |k, v|
            Dependency.new(k, v, nil)
          end
        end

      end
    end
  end
end
