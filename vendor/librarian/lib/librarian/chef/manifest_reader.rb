require 'json'
require 'yaml'

require 'librarian/manifest'

module Librarian
  module Chef
    module ManifestReader
      extend self

      MANIFESTS = %w(metadata.json metadata.yml metadata.yaml metadata.rb)

      def manifest_path(path)
        MANIFESTS.map{|s| path.join(s)}.find{|s| s.exist?}
      end

      def read_manifest(name, manifest_path)
        case manifest_path.extname
        when ".json" then JSON.parse(binread(manifest_path))
        when ".yml", ".yaml" then YAML.load(binread(manifest_path))
        when ".rb" then compile_manifest(name, manifest_path.dirname)
        end
      end

      def compile_manifest(name, path)
        # Inefficient, if there are many cookbooks with uncompiled metadata.
        require 'chef/json_compat'
        require 'chef/cookbook/metadata'
        md = ::Chef::Cookbook::Metadata.new
        md.name(name)
        md.from_file(path.join('metadata.rb').to_s)
        {"name" => md.name, "version" => md.version, "dependencies" => md.dependencies}
      end

      def manifest?(name, path)
        path = Pathname.new(path)
        !!manifest_path(path)
      end

      def check_manifest(name, manifest_path)
        manifest = read_manifest(name, manifest_path)
        manifest["name"] == name
      end

    private

      if IO.respond_to?(:binread)
        def binread(path)
          path.binread
        end
      else
        def binread(path)
          path.read
        end
      end

    end
  end
end
