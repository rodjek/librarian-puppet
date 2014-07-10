require 'librarian/puppet/source/forge/repo'
require 'puppet_forge'
require 'librarian/puppet/version'

module Librarian
  module Puppet
    module Source
      class Forge
        class RepoV3 < Librarian::Puppet::Source::Forge::Repo

          PuppetForge.user_agent = "librarian-puppet/#{Librarian::Puppet::VERSION}"

          def get_versions
            get_module.releases.map{|r| r.version}
          end

          def dependencies(version)
            array = get_release(version).metadata[:dependencies].map{|d| [d['name'], d['version_requirement']]}
            Hash[*array.flatten(1)]
          end

          def url(name, version)
            if name == "#{get_module().owner.username}/#{get_module().name}"
              release = get_release(version)
            else
              # should never get here as we use one repo object for each module (to be changed in the future)
              debug { "Looking up url for #{name}@#{version}" }
              release = PuppetForge::Release.find("#{name}-#{version}")
            end
            "#{source}#{release.file_uri}"
          end

        private

          def get_module
            @module ||= PuppetForge::Module.find(name)
            raise(Error, "Unable to find module '#{name}' on #{source}") unless @module
            @module
          end

          def get_release(version)
            release = get_module.releases.find{|r| r.version == version.to_s}
            if release.nil?
              versions = get_module.releases.map{|r| r.version}
              raise Error, "Unable to find version '#{version}' for module '#{name}' on #{source} amongst #{versions}"
            end
            release
          end

        end
      end
    end
  end
end
