require 'librarian/action/resolve'

module Librarian
  module Puppet
    module Action
      class Resolve < Librarian::Action::Resolve
        include Librarian::Puppet::Util

        def run
          super
          manifests = environment.lock.manifests.select{ |m| m.name }
          dupes = manifests.group_by{ |m| module_name(m.name) }.select { |k, v| v.size > 1 }
          dupes.each do |k,v|
            warn("Dependency on module '#{k}' is fullfilled by multiple modules and only one will be used: #{v.map{|m|m.name}}")
          end
        end

      end
    end
  end
end
