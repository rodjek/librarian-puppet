require "yaml"

require "librarian/config/source"

module Librarian
  module Config
    class FileSource < Source

      attr_accessor :config_path
      private :config_path=

      def initialize(adapter_name, options = { })
        super

        self.config_path = options.delete(:config_path) or raise ArgumentError, "must provide config_path"
      end

      def to_s
        config_path
      end

    private

      def load
        return { } unless File.file?(config_path)

        raw = YAML.load_file(config_path)
        return { } unless Hash === raw

        translate_raw_to_config(raw)
      end

      def save(config)
        raw = translate_config_to_raw(config)

        if config.empty?
          File.delete(config_path) if File.file?(config_path)
        else
          config_dir = File.dirname(config_path)
          FileUtils.mkpath(config_dir) unless File.directory?(config_dir)
          File.open(config_path, "wb"){|f| YAML.dump(raw, f)}
        end
      end

    end
  end
end
