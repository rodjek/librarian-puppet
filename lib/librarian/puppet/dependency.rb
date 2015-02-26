module Librarian
  module Puppet

    class Dependency < Librarian::Dependency

      include Librarian::Puppet::Util

      def initialize(name, requirement, source)
        # Issue #235 fail if forge source is not defined
        raise Error, "forge entry is not defined in Puppetfile" if source.instance_of?(Array) && source.empty?

        super(normalize_name(name), requirement, source)
      end

    end

  end
end
