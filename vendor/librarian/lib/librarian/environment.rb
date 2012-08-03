require "pathname"

require "librarian/support/abstract_method"

require "librarian/error"
require "librarian/config"
require "librarian/lockfile"
require "librarian/logger"
require "librarian/specfile"
require "librarian/resolver"
require "librarian/dsl"
require "librarian/source"

module Librarian
  class Environment

    include Support::AbstractMethod

    attr_accessor :ui

    abstract_method :specfile_name, :dsl_class, :install_path

    def initialize(options = { })
      @pwd = options.fetch(:pwd) { Dir.pwd }
      @env = options.fetch(:env) { ENV.to_hash }
      @home = options.fetch(:home) { File.expand_path("~") }
      @project_path = options[:project_path]
      @specfile_name = options[:specfile_name]
    end

    def logger
      @logger ||= Logger.new(self)
    end

    def config_db
      @config_db ||= begin
        Config::Database.new(adapter_name,
          :pwd => @pwd,
          :env => @env,
          :home => @home,
          :project_path => @project_path,
          :specfile_name => default_specfile_name
        )
      end
    end

    def default_specfile_name
      @default_specfile_name ||= begin
        capped = adapter_name.capitalize
        "#{capped}file"
      end
    end

    def project_path
      config_db.project_path
    end

    def specfile_name
      config_db.specfile_name
    end

    def specfile_path
      config_db.specfile_path
    end

    def specfile
      Specfile.new(self, specfile_path)
    end

    def adapter_name
      nil
    end

    def lockfile_name
      config_db.lockfile_name
    end

    def lockfile_path
      config_db.lockfile_path
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

    def config_keys
      %[
      ]
    end

  private

    def environment
      self
    end

  end
end
