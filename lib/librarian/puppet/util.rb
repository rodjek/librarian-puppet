module Librarian
  module Puppet

    module Util

      def debug(*args, &block)
        environment.logger.debug(*args, &block)
      end
      def info(*args, &block)
        environment.logger.info(*args, &block)
      end
      def warn(*args, &block)
        environment.logger.warn(*args, &block)
      end

      # workaround Issue #173 FileUtils.cp_r will fail if there is a symlink that points to a missing file
      # or when the symlink is copied before the target file when preserve is true
      # see also https://tickets.opscode.com/browse/CHEF-833
      def cp_r(src, dest)
        begin
          FileUtils.cp_r(src, dest, :preserve => true)
        rescue Errno::ENOENT
          debug { "Failed to copy from #{src} to #{dest} preserving file types, trying again without preserving them" }
          FileUtils.rm_rf(dest)
          FileUtils.cp_r(src, dest)
        end
      end

      # Remove user and password from a URI object
      def clean_uri(uri)
        new_uri = uri.clone
        new_uri.user = nil
        new_uri.password = nil
        new_uri
      end

      # normalize module name to use organization-module instead of organization/module
      def normalize_name(name)
        name.sub('/','-')
      end

      # get the organization name from organization-module
      def organization_name(name)
        name.split('-',2).last
      end
    end
  end
end
