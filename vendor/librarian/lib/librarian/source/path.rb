require 'librarian/source/local'

module Librarian
  module Source
    class Path

      include Local

      class << self

        LOCK_NAME = 'PATH'

        def lock_name
          LOCK_NAME
        end

        def from_lock_options(environment, options)
          new(environment, options[:remote], options.reject{|k, v| k == :remote})
        end

        def from_spec_args(environment, path, options)
          recognized_options = []
          unrecognized_options = options.keys - recognized_options
          unrecognized_options.empty? or raise Error, "unrecognized options: #{unrecognized_options.join(", ")}"

          new(environment, path, options)
        end

      end

      attr_accessor :environment
      private :environment=
      attr_reader :path

      def initialize(environment, path, options)
        self.environment = environment
        @path = path
      end

      def to_s
        path.to_s
      end

      def ==(other)
        other &&
        self.class  == other.class &&
        self.path   == other.path
      end

      alias :eql? :==

      def hash
        self.to_s.hash
      end

      def to_spec_args
        [path.to_s, {}]
      end

      def to_lock_options
        {:remote => path}
      end

      def pinned?
        false
      end

      def unpin!
      end

      def cache!
      end

      def filesystem_path
        @filesystem_path ||= Pathname.new(path).expand_path(environment.project_path)
      end

    end
  end
end
