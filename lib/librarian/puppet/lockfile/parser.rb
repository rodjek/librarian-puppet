require 'librarian/manifest'
require 'librarian/dependency'
require 'librarian/manifest_set'

module Librarian
  class Lockfile
    class Parser
      include Librarian::Puppet::Util

      def parse(string)
        string = string.dup
        source_type_names_map = Hash[dsl_class.source_types.map{|t| [t[1].lock_name, t[1]]}]
        source_type_names = dsl_class.source_types.map{|t| t[1].lock_name}
        lines = string.split(/(\r|\n|\r\n)+/).select{|l| l =~ /\S/}
        sources = []
        while source_type_names.include?(lines.first)
          source = {}
          source_type_name = lines.shift
          source[:type] = source_type_names_map[source_type_name]
          options = {}
          while lines.first =~ /^ {2}([\w\-\/]+):\s+(.+)$/
            lines.shift
            options[$1.to_sym] = $2
          end
          source[:options] = options
          lines.shift # specs
          manifests = {}
          while lines.first =~ /^ {4}([\w\-\/]+) \((.*)\)$/ # This change allows forward slash
            lines.shift
            name, version = normalize_name($1), $2
            manifests[name] = {:version => version, :dependencies => {}}
            while lines.first =~ /^ {6}([\w\-\/]+) \((.*)\)$/
              lines.shift
              manifests[name][:dependencies][$1] = $2.split(/,\s*/)
            end
          end
          source[:manifests] = manifests
          sources << source
        end
        manifests = compile(sources)
        manifests_index = Hash[manifests.map{|m| [m.name, m]}]
        raise StandardError, "Expected DEPENDENCIES topic!" unless lines.shift == "DEPENDENCIES"
        dependencies = []
        while lines.first =~ /^ {2}([\w\-\/]+)(?: \((.*)\))?$/ # This change allows forward slash
          lines.shift
          name, requirement = normalize_name($1), $2.split(/,\s*/)
          dependencies << Dependency.new(name, requirement, manifests_index[name].source)
        end

        Resolution.new(dependencies, manifests)
      end

    end
  end
end
