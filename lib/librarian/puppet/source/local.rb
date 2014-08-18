require 'librarian/puppet/util'

module Librarian
  module Puppet
    module Source
      module Local
        include Librarian::Puppet::Util

        def install!(manifest)
          manifest.source == self or raise ArgumentError

          debug { "Installing #{manifest}" }

          name, version = manifest.name, manifest.version
          found_path = found_path(name)
          raise Error, "Path for #{name} doesn't contain a puppet module" if found_path.nil?

          unless name.include? '/' or name.include? '-'
            warn { "Invalid module name '#{name}', you should qualify it with 'ORGANIZATION-#{name}' for resolution to work correctly" }
          end

          install_path = environment.install_path.join(organization_name(name))
          if install_path.exist?
            debug { "Deleting #{relative_path_to(install_path)}" }
            install_path.rmtree
          end

          install_perform_step_copy!(found_path, install_path)
        end

        def fetch_version(name, extra)
          cache!
          found_path = found_path(name)
          module_version
        end

        def fetch_dependencies(name, version, extra)
          dependencies = Set.new

          if specfile?
            spec = environment.dsl(Pathname(specfile))
            dependencies.merge spec.dependencies
          end

          parsed_metadata['dependencies'].each do |d|
            gem_requirement = Requirement.new(d['version_requirement']).gem_requirement
            new_dependency = Dependency.new(d['name'], gem_requirement, forge_source)
            # Avoid duplicated dependencies with different sources
            unless dependencies.find { |spec_dependency| spec_dependency.name == new_dependency.name && spec_dependency.requirement == new_dependency.requirement }
              dependencies << new_dependency
            end
          end

          dependencies
        end

        def forge_source
          Forge.from_lock_options(environment, :remote => "https://forge.puppetlabs.com")
        end

        private

        # Naming this method 'version' causes an exception to be raised.
        def module_version
          if parsed_metadata['version']
            parsed_metadata['version']
          else
            warn { "Module #{to_s} does not have version, defaulting to 0.0.1" }
            '0.0.1'
          end
        end

        def require_puppet
          begin
            require 'puppet'
            require 'puppet/module_tool'
          rescue LoadError
            $stderr.puts <<-EOF
          Unable to load puppet, the puppet gem is required for :git and :path source.
          Install it with: gem install puppet
            EOF
            exit 1
          end
          true
        end

        def evaluate_modulefile(modulefile)
          @@require_puppet ||= require_puppet

          metadata = ::Puppet::ModuleTool::Metadata.new
          begin
            ::Puppet::ModuleTool::ModulefileReader.evaluate(metadata, modulefile)
            raise SyntaxError, "Missing version" unless metadata.version
          rescue ArgumentError, SyntaxError => error
            warn { "Unable to parse #{modulefile}, ignoring: #{error}" }
            if metadata.respond_to? :version=
              metadata.version = '0.0.1' # puppet < 3.6
            else
              metadata.update({'version' => '0.0.1'}) # puppet >= 3.6
            end
          end
          metadata
        end

        def parsed_metadata
          @metadata ||= if metadata?
            JSON.parse(File.read(metadata))
          elsif modulefile?
            # translate Modulefile to metadata.json
            evaluated = evaluate_modulefile(modulefile)
            {
              'version' => evaluated.version,
              'dependencies' => evaluated.dependencies.map do |dependency|
                {
                  'name' => dependency.instance_variable_get(:@full_module_name),
                  'version_requirement' => dependency.instance_variable_get(:@version_requirement)
                }
              end
            }
          else
            {
              'dependencies' => []
            }
          end
          @metadata
        end

        def modulefile
          File.join(filesystem_path, 'Modulefile')
        end

        def modulefile?
          File.exists?(modulefile)
        end

        def metadata
          File.join(filesystem_path, 'metadata.json')
        end

        def metadata?
          File.exists?(metadata)
        end

        def specfile
          File.join(filesystem_path, environment.specfile_name)
        end

        def specfile?
          File.exists?(specfile)
        end

        def install_perform_step_copy!(found_path, install_path)
          debug { "Copying #{relative_path_to(found_path)} to #{relative_path_to(install_path)}" }
          cp_r(found_path, install_path)
        end

        def manifest?(name, path)
          return true if path.join('manifests').exist?
          return true if path.join('lib').join('puppet').exist?
          return true if path.join('lib').join('facter').exist?
          debug { "Could not find manifests, lib/puppet or lib/facter under #{path}, assuming is not a puppet module" }
          false
        end
      end
    end
  end
end
