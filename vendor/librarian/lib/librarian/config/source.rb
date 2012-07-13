require "librarian/error"

module Librarian
  module Config
    class Source

      RAW_KEY_SUFFIX_VALIDITY_PATTERN =
        /\A[A-Z0-9_]+\z/
      CONFIG_KEY_VALIDITY_PATTERN =
        /\A[a-z][a-z0-9\-]+(?:\.[a-z0-9\-]+)*\z/

      class << self
        def raw_key_suffix_validity_pattern
          RAW_KEY_SUFFIX_VALIDITY_PATTERN
        end
        def config_key_validity_pattern
          CONFIG_KEY_VALIDITY_PATTERN
        end
      end

      attr_accessor :adapter_name
      private :adapter_name=

      def initialize(adapter_name, options = { })
        self.adapter_name = adapter_name

        self.forbidden_keys = options.delete(:forbidden_keys) || []
      end

      def [](key)
        load!

        data[key]
      end

      def []=(key, value)
        key_permitted?(key) or raise Error, "key not permitted: #{key.inspect}"
        value_permitted?(key, value) or raise Error, "value for key #{key.inspect} not permitted: #{value.inspect}"

        load!
        if value.nil?
          data.delete(key)
        else
          data[key] = value
        end
        save(data)
      end

      def keys
        load!

        data.keys
      end

    private

      attr_accessor :data, :forbidden_keys

      def load!
        self.data = load unless data
      end

      def key_permitted?(key)
        String === key &&
        config_key_validity_pattern === key &&
        !forbidden_keys.any?{|k| k === key}
      end

      def value_permitted?(key, value)
        return true if value.nil?

        String === value
      end

      def raw_key_valid?(key)
        return false unless key.start_with?(raw_key_prefix)

        suffix = key[raw_key_prefix.size..-1]
        raw_key_suffix_validity_pattern =~ suffix
      end

      def raw_key_suffix_validity_pattern
        self.class.raw_key_suffix_validity_pattern
      end

      def config_key_valid?(key)
        config_key_validity_pattern === key
      end

      def config_key_validity_pattern
        self.class.config_key_validity_pattern
      end

      def raw_key_prefix
        @key_prefix ||= "LIBRARIAN_#{adapter_name.upcase}_"
      end

      def assert_raw_keys_valid!(raw)
        bad_keys = raw.keys.reject{|k| raw_key_valid?(k)}
        unless bad_keys.empty?
          config_path_s = config_path.to_s.inspect
          bad_keys_s = bad_keys.map(&:inspect).join(", ")
          raise Error, "config #{to_s} has bad keys: #{bad_keys_s}"
        end
      end

      def assert_config_keys_valid!(config)
        bad_keys = config.keys.reject{|k| config_key_valid?(k)}
        unless bad_keys.empty?
          bad_keys_s = bad_keys.map(&:inspect).join(", ")
          raise Error, "config has bad keys: #{bad_keys_s}"
        end
      end

      def assert_values_valid!(data)
        bad_data = data.reject{|k, v| String === v}
        bad_keys = bad_data.keys

        unless bad_keys.empty?
          bad_keys_s = bad_keys.map(&:inspect).join(", ")
          raise Error, "config has bad values for keys: #{bad_keys_s}"
        end
      end

      def translate_raw_to_config(raw)
        assert_raw_keys_valid!(raw)
        assert_values_valid!(raw)

        Hash[raw.map do |key, value|
          key = key[raw_key_prefix.size .. -1]
          key = key.downcase.gsub(/__/, ".").gsub(/_/, "-")
          [key, value]
        end]
      end

      def translate_config_to_raw(config)
        assert_config_keys_valid!(config)
        assert_values_valid!(config)

        Hash[config.map do |key, value|
          key = key.gsub(/\./, "__").gsub(/\-/, "_").upcase
          key = "#{raw_key_prefix}#{key}"
          [key, value]
        end]
      end

    end
  end
end
