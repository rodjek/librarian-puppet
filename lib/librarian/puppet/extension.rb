require 'librarian/puppet/environment'
require 'librarian/action/base'

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

  # Fixes for librarian not yet released in their gem
  module Mock
    module Source
      class Mock
        alias :eql? :==

        def hash
          self.to_s.hash
        end
      end
    end
  end
  module Source
    class Git
      alias :eql? :==

      def hash
        self.to_s.hash
      end
    end

    class Path
      alias :eql? :==

      def hash
        self.to_s.hash
      end
    end
  end


  module Action
    class Install < Base

    private

      def create_install_path
        install_path.rmtree if install_path.exist? && destructive?
        install_path.mkpath
      end

      def destructive?
        environment.config_db.local['destructive'] == 'true'
      end
    end
  end

  class ManifestSet
    private

    # Check if module doesn't exist and fail fast
    def dependencies_of(names)
      names = Array === names ? names.dup : names.to_a
      assert_strings!(names)

      deps = Set.new
      until names.empty?
        name = names.shift
        next if deps.include?(name)

        deps << name
        raise(Error, "Unable to find module #{name}") if index[name].nil?
        names.concat index[name].dependencies.map(&:name)
      end
      deps.to_a
    end
  end
end
