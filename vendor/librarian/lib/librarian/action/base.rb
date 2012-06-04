require "librarian/helpers/debug"

module Librarian
  module Action
    class Base

      include Helpers::Debug

      attr_accessor :environment
      private :environment=

      attr_accessor :options
      private :options=

      def initialize(environment, options = { })
        self.environment = environment
        self.options = options
      end

    end
  end
end
