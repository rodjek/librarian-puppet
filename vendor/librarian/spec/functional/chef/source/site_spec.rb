require 'pathname'
require 'json'
require 'webmock'

require 'librarian'
require 'librarian/helpers'
require 'librarian/action/resolve'
require 'librarian/action/install'
require 'librarian/chef'

module Librarian
  module Chef
    module Source
      describe Site do

        include WebMock::API

        let(:project_path) do
          project_path = Pathname.new(__FILE__).expand_path
          project_path = project_path.dirname until project_path.join("Rakefile").exist?
          project_path
        end
        let(:tmp_path) { project_path.join("tmp/spec/chef/site-source") }
        let(:sample_path) { tmp_path.join("sample") }
        let(:sample_metadata) do
          Helpers.strip_heredoc(<<-METADATA)
            version "0.6.5"
          METADATA
        end

        let(:api_url) { "http://site.cookbooks.com" }

        let(:sample_index_data) do
          {
            "name" => "sample",
            "versions" => [
              "#{api_url}/cookbooks/sample/versions/0_6_5"
            ]
          }
        end
        let(:sample_0_6_5_data) do
          {
            "version" => "0.6.5",
            "file" => "#{api_url}/cookbooks/sample/versions/0_6_5/file.tar.gz"
          }
        end

        # depends on repo_path being defined in each context
        let(:env) { Environment.new(:project_path => repo_path) }

        before :all do
          sample_path.rmtree if sample_path.exist?
          sample_path.mkpath
          sample_path.join("metadata.rb").open("wb") { |f| f.write(sample_metadata) }
          Dir.chdir(sample_path.dirname) do
            system "tar --create --gzip --file sample.tar.gz #{sample_path.basename}"
          end
        end

        before do
          stub_request(:get, "#{api_url}/cookbooks/sample").
            to_return(:body => JSON.dump(sample_index_data))

          stub_request(:get, "#{api_url}/cookbooks/sample/versions/0_6_5").
            to_return(:body => JSON.dump(sample_0_6_5_data))

          stub_request(:get, "#{api_url}/cookbooks/sample/versions/0_6_5/file.tar.gz").
            to_return(:body => sample_path.dirname.join("sample.tar.gz").read)
        end

        after do
          WebMock.reset!
        end

        context "a single dependency with a site source" do

          context "resolving" do
            let(:repo_path) { tmp_path.join("repo/resolve") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("cookbooks").mkpath
              cheffile = Helpers.strip_heredoc(<<-CHEFFILE)
                #!/usr/bin/env ruby
                cookbook "sample", :site => #{api_url.inspect}
              CHEFFILE
              repo_path.join("Cheffile").open("wb") { |f| f.write(cheffile) }
            end

            context "the resolve" do
              it "should not raise an exception" do
                expect { Action::Resolve.new(env).run }.to_not raise_error
              end
            end

            context "the results" do
              before { Action::Resolve.new(env).run }

              it "should create the lockfile" do
                repo_path.join("Cheffile.lock").should exist
              end

              it "should not attempt to install the cookbok" do
                repo_path.join("cookbooks/sample").should_not exist
              end
            end
          end

          context "intalling" do
            let(:repo_path) { tmp_path.join("repo/install") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("cookbooks").mkpath
              cheffile = Helpers.strip_heredoc(<<-CHEFFILE)
                #!/usr/bin/env ruby
                cookbook "sample", :site => #{api_url.inspect}
              CHEFFILE
              repo_path.join("Cheffile").open("wb") { |f| f.write(cheffile) }

              Action::Resolve.new(env).run
            end

            context "the install" do
              it "should not raise an exception" do
                expect { Action::Install.new(env).run }.to_not raise_error
              end
            end

            context "the results" do
              before { Action::Install.new(env).run }

              it "should create the lockfile" do
                repo_path.join("Cheffile.lock").should exist
              end

              it "should create a directory for the cookbook" do
                repo_path.join("cookbooks/sample").should exist
              end

              it "should copy the cookbook files into the cookbook directory" do
                repo_path.join("cookbooks/sample/metadata.rb").should exist
              end
            end
          end

          context "resolving and separately installing" do
            let(:repo_path) { tmp_path.join("repo/resolve-install") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("cookbooks").mkpath
              cheffile = Helpers.strip_heredoc(<<-CHEFFILE)
                #!/usr/bin/env ruby
                cookbook "sample", :site => #{api_url.inspect}
              CHEFFILE
              repo_path.join("Cheffile").open("wb") { |f| f.write(cheffile) }

              Action::Resolve.new(env).run
              repo_path.join("tmp").rmtree if repo_path.join("tmp").exist?
            end

            context "the install" do
              it "should not raise an exception" do
                expect { Action::Install.new(env).run }.to_not raise_error
              end
            end

            context "the results" do
              before { Action::Install.new(env).run }

              it "should create a directory for the cookbook" do
                repo_path.join("cookbooks/sample").should exist
              end

              it "should copy the cookbook files into the cookbook directory" do
                repo_path.join("cookbooks/sample/metadata.rb").should exist
              end
            end
          end

        end

        context "when the repo path has a space" do

          let(:repo_path) { tmp_path.join("repo/with extra spaces/resolve") }

          before do
            repo_path.rmtree if repo_path.exist?
            repo_path.mkpath
            repo_path.join("cookbooks").mkpath

            cheffile = Helpers.strip_heredoc(<<-CHEFFILE)
              #!/usr/bin/env ruby
              cookbook "sample", :site => #{api_url.inspect}
            CHEFFILE
            repo_path.join("Cheffile").open("wb") { |f| f.write(cheffile) }
          end

          after do
            repo_path.rmtree
          end

          context "the resolution" do
            it "should not raise an exception" do
              expect { Action::Resolve.new(env).run }.to_not raise_error
            end
          end

        end

      end
    end
  end
end
