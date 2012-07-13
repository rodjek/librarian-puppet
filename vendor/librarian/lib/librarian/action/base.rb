module Librarian
  module Action
    class Base

      attr_accessor :environment
      private :environment=

      attr_accessor :options
      private :options=

      def initialize(environment, options = { })
        self.environment = environment
        self.options = options
      end

    private

      def debug(*args, &block)
        environment.logger.debug(*args, &block)
      end

    end
  end
end
