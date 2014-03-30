module Librarian
  module Puppet
    module Action
      class Install < Librarian::Action::Install

        private

        def create_install_path
          install_path.rmtree if install_path.exist? && destructive?
          install_path.mkpath
        end

        def destructive?
          environment.config_db.local['destructive'] == 'true'
        end

        def check_specfile
          # don't fail if Puppetfile doesn't exist as we'll use the Modulefile or metadata.json
        end

      end
    end
  end
end
