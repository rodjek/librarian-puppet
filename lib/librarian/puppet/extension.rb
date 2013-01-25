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
            # Gem::Requirement, convert to string (ie. =1.0) so we can concat later
            # Gem::Requirements can not be concatenated
            arg.requirements.map{|x,y| "#{x}#{y}"}
          end
        end.flatten
      end

      # convert Puppet versions to gem supported versions
      # '1.x' to '~>1.0'
      # '>=1.1.0 <2.0.0' to ['>=1.1.0', '<2.0.0']
      # http://docs.puppetlabs.com/puppet/2.7/reference/modules_publishing.html
      def puppet_to_gem_version(version)
        constraints = version.scan(/([~<>=]*[ ]*[\d\.x]+)/).flatten # split the constraints
        constraints.map do |constraint|
          matched = /(.*)\.x/.match(constraint)
          matched.nil? ? constraint : "~>#{matched[1]}.0"
        end
      end
    end
  end
end
