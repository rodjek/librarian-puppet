module Librarian
  module Puppet
    class Requirement
      attr_reader :requirement

      def initialize(requirement)
        @requirement = requirement
      end

      # convert Puppet versions to gem supported versions
      # '1.x' to '~>1.0'
      # '>=1.1.0 <2.0.0' to ['>=1.1.0', '<2.0.0']
      # http://docs.puppetlabs.com/puppet/2.7/reference/modules_publishing.html
      def gem_requirement
        if range_requirement?
          [@range_match[1], @range_match[2]]
        elsif pessimistic_requirement?
          "~> #{@pessimistic_match[1]}.0"
        else
          requirement
        end
      end

      def to_s
        gem_requirement.to_s
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
