require 'librarian/puppet/environment'
require 'librarian/action/base'

module Librarian
  module Puppet
    extend self
    extend Librarian
  end

  class Dependency
    include Librarian::Puppet::Util

    def initialize(name, requirement, source)
      assert_name_valid! name

      # Issue #235 fail if forge source is not defined
      raise Error, "forge entry is not defined in Puppetfile" if source.instance_of?(Array) && source.empty?

      # let's settle on provider-module syntax instead of provider/module
      self.name = normalize_name(name)
      self.requirement = Requirement.new(requirement)
      self.source = source

      @manifests = nil
    end

  end

end
