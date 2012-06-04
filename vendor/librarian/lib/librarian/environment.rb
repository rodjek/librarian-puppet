require "pathname"

require "librarian/helpers/debug"
require "librarian/support/abstract_method"

require "librarian/error"
require "librarian/lockfile"
require "librarian/specfile"
require "librarian/resolver"
require "librarian/dsl"
require "librarian/source"

module Librarian
  class Environment

    include Support::AbstractMethod
    include Helpers::Debug

    attr_accessor :ui

    abstract_method :specfile_name, :dsl_class, :install_path

    def initialize(options = { })
      @project_path = options[:project_path]
      @specfile_name = options[:specfile_name]
    end

    def project_path
      @project_path ||= begin
        root = Pathname.new(Dir.pwd)
        root = root.dirname until project_path?(root)
        path = root.join(specfile_name)
        path.file? ? root : nil
      end
    end

    def project_path?(path)
      path.join(config_name).directory? ||
      path.join(specfile_name).file? ||
      path.dirname == path
    end

    def default_specfile_name
      @default_specfile_name ||= begin
        capped = adapter_name.capitalize
        "#{capped}file"
      end
    end

    def specfile_name
      @specfile_name ||= default_specfile_name
    end

    def specfile_path
      project_path.join(specfile_name)
    end

    def specfile
      Specfile.new(self, specfile_path)
    end

    def adapter_name
      nil
    end

    def config_name
      File.join(*[config_prefix, adapter_name].compact)
    end

    def config_prefix
      ".librarian"
    end

    def lockfile_name
      "#{specfile_name}.lock"
    end

    def lockfile_path
      project_path.join(lockfile_name)
    end

    def lockfile
      Lockfile.new(self, lockfile_path)
    end

    def ephemeral_lockfile
      Lockfile.new(self, nil)
    end

    def resolver
      Resolver.new(self)
    end

    def cache_path
      project_path.join("tmp/librarian/cache")
    end

    def scratch_path
      project_path.join("tmp/librarian/scratch")
    end

    def project_relative_path_to(path)
      Pathname.new(path).relative_path_from(project_path)
    end

    def spec
      specfile.read
    end

    def lock
      lockfile.read
    end

    def dsl(*args, &block)
      dsl_class.run(self, *args, &block)
    end

    def dsl_class
      self.class.name.split("::")[0 ... -1].inject(Object, &:const_get)::Dsl
    end

  private

    def environment
      self
    end

  end
end
