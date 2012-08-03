require 'librarian/source/git'
require 'librarian/chef/source/local'

module Librarian
  module Chef
    module Source
      class Git < Librarian::Source::Git
        include Local

      private

        def install_perform_step_copy!(found_path, install_path)
          debug { "Copying #{relative_path_to(found_path)} to #{relative_path_to(install_path)}" }
          FileUtils.cp_r(found_path, install_path)

          if environment.config_db["install.strip-dot-git"] == "1"
            dot_git = install_path.join(".git")
            dot_git.rmtree if dot_git.directory?
          end
        end

      end
    end
  end
end
