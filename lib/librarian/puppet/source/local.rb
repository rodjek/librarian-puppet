begin
  require 'puppet'
rescue LoadError
  $stderr.puts <<-EOF
Unable to load puppet, the puppet gem is required for :git and :path source.
Install it with: gem install puppet
  EOF
  exit 1
end

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

          unless name.include? '/'
            warn { "Invalid module name '#{name}', you should qualify it with 'ORGANIZATION/#{name}' for resolution to work correctly" }
          end

          install_path = environment.install_path.join(name.split('/').last)
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
          dependencies = {}

          if modulefile?
            evaluate_modulefile(modulefile).dependencies.each do |dependency|
              dependency_name = dependency.instance_variable_get(:@full_module_name)
              version = dependency.instance_variable_get(:@version_requirement)
              gem_requirement = Requirement.new(version).gem_requirement
              dependencies[dependency_name] = Dependency.new(dependency_name, gem_requirement, forge_source)
            end
          end

          if specfile?
            spec = environment.dsl(Pathname(specfile))
            spec.dependencies.each do |dependency|
              module_dependency = dependencies[dependency.name]
              if module_dependency.nil?
                warn { "Module #{name}: its dependency #{dependency.name} only found in Puppetfile and not in Modulefile" }
                dependencies[dependency.name] = dependency
              else
                if module_dependency == dependency
                  dependencies[dependency.name] = dependency
                else
                  warn { "Module #{name}: its dependency #{dependency.name} was found in Puppetfile with different requirements than in Modulefile, ignoring the Puppetfile one" }
                end
              end
            end
          end

          dependencies.values
        end

        def forge_source
          Forge.from_lock_options(environment, :remote=>"http://forge.puppetlabs.com")
        end

        private

        # Naming this method 'version' causes an exception to be raised.
        def module_version
          return '0.0.1' unless modulefile?
          evaluate_modulefile(modulefile).version
        end

        def evaluate_modulefile(modulefile)
          metadata = ::Puppet::ModuleTool::Metadata.new
          begin
            ::Puppet::ModuleTool::ModulefileReader.evaluate(metadata, modulefile)
          rescue ArgumentError, SyntaxError => error
            warn { "Unable to parse #{modulefile}, ignoring: #{error}" }
            metadata.version = '0.0.1'
          end
          metadata
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
