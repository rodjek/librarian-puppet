require "librarian/source"

module Librarian
  module Config
    class HashSource < Source

      attr_accessor :name, :raw
      private :name=, :raw=

      def initialize(adapter_name, options = { })
        super

        self.name = options.delete(:name) or raise ArgumentError, "must provide name"
        self.raw = options.delete(:raw) or raise ArgumentError, "must provide raw"
      end

      def to_s
        name
      end

    private

      def load
        translate_raw_to_config(raw)
      end

      def save(config)
        raise Error, "nonsense!"
      end

    end
  end
end
