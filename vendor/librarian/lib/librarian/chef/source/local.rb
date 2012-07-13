require 'librarian/chef/manifest_reader'

module Librarian
  module Chef
    module Source
      module Local

        def install!(manifest)
          manifest.source == self or raise ArgumentError

          info { "Installing #{manifest.name} (#{manifest.version})" }

          debug { "Installing #{manifest}" }

          name, version = manifest.name, manifest.version
          found_path = found_path(name)

          install_path = environment.install_path.join(name)
          if install_path.exist?
            debug { "Deleting #{relative_path_to(install_path)}" }
            install_path.rmtree
          end

          install_perform_step_copy!(found_path, install_path)
        end

        def fetch_version(name, extra)
          manifest_data(name)["version"]
        end

        def fetch_dependencies(name, version, extra)
          manifest_data(name)["dependencies"]
        end

      private

        def install_perform_step_copy!(found_path, install_path)
          debug { "Copying #{relative_path_to(found_path)} to #{relative_path_to(install_path)}" }
          FileUtils.cp_r(found_path, install_path)
        end

        def manifest_data(name)
          @manifest_data ||= { }
          @manifest_data[name] ||= fetch_manifest_data(name)
        end

        def fetch_manifest_data(name)
          expect_manifest!(name)

          found_path = found_path(name)
          manifest_path = ManifestReader.manifest_path(found_path)
          ManifestReader.read_manifest(name, manifest_path)
        end

        def manifest?(name, path)
          ManifestReader.manifest?(name, path)
        end

        def expect_manifest!(name)
          found_path = found_path(name)
          return if found_path && ManifestReader.manifest_path(found_path)

          raise Error, "No metadata file found for #{name} from #{self}! If this should be a cookbook, you might consider contributing a metadata file upstream or forking the cookbook to add your own metadata file."
        end

      end
    end
  end
end
