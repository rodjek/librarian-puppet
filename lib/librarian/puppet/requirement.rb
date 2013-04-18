module Librarian
  module Puppet
    class Requirement
      attr_reader :requirement

      def initialize(requirement)
        @requirement = requirement
      end

      def gem_requirement
        if range_requirement?
          [@range_match[1], @range_match[2]]
        elsif pessimistic_requirement?
          "~> #{@pessimistic_match[1]}"
        else
          requirement
        end
      end

      private

      def range_requirement?
        @range_match ||= requirement.match(/(>=? ?\d+(?:\.\d+){0,2}) (<=? ?\d+(?:\.\d+){0,2})/)
      end

      def pessimistic_requirement?
        @pessimistic_match ||= requirement.match(/(\d+(?:\.\d+)?)\.x/)
      end
    end
  end
end
