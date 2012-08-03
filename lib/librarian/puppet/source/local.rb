module Librarian
  module Puppet
    module Source
      module Local

        def install!(manifest)
          manifest.source == self or raise ArgumentError

          debug { "Installing #{manifest}" }

          name, version = manifest.name, manifest.version
          found_path = found_path(name)

          if name.include? '/'
            new_name = name.split('/').last
            debug { "Invalid module name '#{name}', guessing you meant '#{new_name}'" }
            name = new_name
          end

          install_path = environment.install_path.join(name)
          if install_path.exist?
            debug { "Deleting #{relative_path_to(install_path)}" }
            install_path.rmtree
          end

          install_perform_step_copy!(found_path, install_path)
        end

        def fetch_version(name, extra)
          cache!
          found_path = found_path(name)
          '0.0.1'
        end

        def fetch_dependencies(name, version, extra)
          {}
        end

      private

        def install_perform_step_copy!(found_path, install_path)
          debug { "Copying #{relative_path_to(found_path)} to #{relative_path_to(install_path)}" }
          FileUtils.cp_r(found_path, install_path)
        end

        def manifest?(name, path)
          return true if path.join('manifests').exist?
          return true if path.join('lib').join('puppet').exist?
          return true if path.join('lib').join('facter').exist?
          false
        end
      end
    end
  end
end
