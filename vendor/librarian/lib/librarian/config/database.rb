require "pathname"

require "librarian/config/file_source"
require "librarian/config/hash_source"

module Librarian
  module Config
    class Database

      class << self
        def library
          name.split("::").first.downcase
        end
      end

      attr_accessor :adapter_name
      private :adapter_name=

      attr_accessor :root, :assigned_specfile_name
      private :root=, :assigned_specfile_name=

      attr_accessor :underlying_env, :underlying_pwd, :underlying_home
      private :underlying_env=, :underlying_pwd=, :underlying_home=

      def initialize(adapter_name, options = { })
        self.adapter_name = adapter_name or raise ArgumentError, "must provide adapter_name"

        options[:project_path] || options[:pwd] or raise ArgumentError, "must provide project_path or pwd"

        self.root = options[:project_path] && Pathname(options[:project_path])
        self.assigned_specfile_name = options[:specfile_name]
        self.underlying_env = options[:env] or raise ArgumentError, "must provide env"
        self.underlying_pwd = options[:pwd] && Pathname(options[:pwd])
        self.underlying_home = options[:home] && Pathname(options[:home])
      end

      def global
        memo(__method__) { new_file_source(global_config_path) }
      end

      def env
        memo(__method__) { HashSource.new(adapter_name, :name => "environment", :raw => env_source_data) }
      end

      def local
        memo(__method__) { new_file_source(local_config_path) }
      end

      def [](key, scope = nil)
        case scope
        when "local", :local then local[key]
        when "env", :env then env[key]
        when "global", :global then global[key]
        when nil then local[key] || env[key] || global[key]
        else raise Error, "bad scope"
        end
      end

      def []=(key, scope, value)
        case scope
        when "local", :local then local[key] = value
        when "global", :global then global[key] = value
        else raise Error, "bad scope"
        end
      end

      def keys
        [local, env, global].inject([]){|a, e| a.concat(e.keys) ; a}.sort.uniq
      end

      def project_path
        root || specfile_path.dirname
      end

      def specfile_path
        if root
          root + (assigned_specfile_name || default_specfile_name)
        else
          env_specfile_path || default_specfile_path
        end
      end

      def specfile_name
        specfile_path.basename.to_s
      end

      def lockfile_path
        project_path + lockfile_name
      end

      def lockfile_name
        "#{specfile_name}.lock"
      end

    private

      def new_file_source(config_path)
        return unless config_path

        FileSource.new(adapter_name,
          :config_path => config_path,
          :forbidden_keys => [config_key, specfile_key]
        )
      end

      def global_config_path
        env_global_config_path || default_global_config_path
      end

      def env_global_config_path
        memo(__method__) { env[config_key] }
      end

      def default_global_config_path
        underlying_home && underlying_home + config_name
      end

      def local_config_path
        root_local_config_path || env_local_config_path || default_local_config_path
      end

      def root_local_config_path
        root && root + config_name
      end

      def env_specfile_path
        memo(__method__) do
          path = env[specfile_key]
          path && Pathname(path)
        end
      end

      def default_specfile_path
        default_project_root_path + (assigned_specfile_name || default_specfile_name)
      end

      def env_local_config_path
        return unless env_specfile_path

        env_specfile_path.dirname + config_name
      end

      def default_local_config_path
        default_project_root_path + config_name
      end

      def default_project_root_path
        if root
          root
        else
          path = underlying_pwd
          path = path.dirname until project_root_path?(path) || path.dirname == path
          project_root_path?(path) ? path : underlying_pwd
        end
      end

      def project_root_path?(path)
        File.file?(path + default_specfile_name)
      end

      def config_key
        "config"
      end

      def specfile_key
        "#{adapter_name}file"
      end

      def default_specfile_name
        "#{adapter_name.capitalize}file"
      end

      def library
        self.class.library
      end

      def config_name_prefix
        ".#{library}"
      end

      def config_name
        File.join(*[config_name_prefix, adapter_name, "config"])
      end

      def raw_key_prefix
        "#{library.upcase}_#{adapter_name.upcase}_"
      end

      def env_source_data
        prefix = raw_key_prefix

        data = underlying_env.dup
        data.reject!{|k, _| !k.start_with?(prefix) || k.size <= prefix.size}
        data
      end

      def memo(key)
        key = "@#{key}"
        instance_variable_set(key, yield) unless instance_variable_defined?(key)
        instance_variable_get(key)
      end

    end
  end
end
