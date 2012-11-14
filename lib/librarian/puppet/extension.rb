require 'librarian/puppet/environment'

module Librarian
  module Puppet
    extend self
    extend Librarian

  end
end

module Librarian
  class Dependency
    class Requirement
      def initialize(*args)
        args = initialize_normalize_args(args)
        self.backing = Gem::Requirement.create(puppet_to_gem_versions(args))
      end

      def puppet_to_gem_versions(args)
        args.map do |arg|
          case arg
          when Array
            arg.map { |v| puppet_to_gem_version(v) }
          when String
            puppet_to_gem_version(arg)
          else
            # Gem::Requirement, do nothing
            arg
          end
        end
      end

      # convert Puppet '1.x' versions to gem supported versions '~>1.0'
      # http://docs.puppetlabs.com/puppet/2.7/reference/modules_publishing.html
      def puppet_to_gem_version(version)
        matched = /(.*)\.x/.match(version)
        matched.nil? ? version : "~>#{matched[1]}.0"
      end
    end
  end
end
