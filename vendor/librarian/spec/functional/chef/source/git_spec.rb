require 'pathname'
require 'securerandom'

require 'librarian'
require 'librarian/helpers'
require 'librarian/error'
require 'librarian/action/resolve'
require 'librarian/action/install'
require 'librarian/action/update'
require 'librarian/chef'

module Librarian
  module Chef
    module Source
      describe Git do

        let(:project_path) do
          project_path = Pathname.new(__FILE__).expand_path
          project_path = project_path.dirname until project_path.join("Rakefile").exist?
          project_path
        end
        let(:tmp_path) { project_path.join("tmp/spec/chef/git-source") }

        let(:cookbooks_path) { tmp_path.join("cookbooks") }

        # depends on repo_path being defined in each context
        let(:env) { Environment.new(:project_path => repo_path) }

        context "a single dependency with a git source" do

          let(:sample_path) { tmp_path.join("sample") }
          let(:sample_metadata) do
            Helpers.strip_heredoc(<<-METADATA)
              version "0.6.5"
            METADATA
          end

          let(:first_sample_path) { cookbooks_path.join("first-sample") }
          let(:first_sample_metadata) do
            Helpers.strip_heredoc(<<-METADATA)
              version "3.2.1"
            METADATA
          end

          let(:second_sample_path) { cookbooks_path.join("second-sample") }
          let(:second_sample_metadata) do
            Helpers.strip_heredoc(<<-METADATA)
              version "4.3.2"
            METADATA
          end

          before :all do
            sample_path.rmtree if sample_path.exist?
            sample_path.mkpath
            sample_path.join("metadata.rb").open("wb") { |f| f.write(sample_metadata) }
            Dir.chdir(sample_path) do
              `git init`
              `git add metadata.rb`
              `git commit -m "Initial commit."`
            end

            cookbooks_path.rmtree if cookbooks_path.exist?
            cookbooks_path.mkpath
            first_sample_path.mkpath
            first_sample_path.join("metadata.rb").open("wb") { |f| f.write(first_sample_metadata) }
            second_sample_path.mkpath
            second_sample_path.join("metadata.rb").open("wb") { |f| f.write(second_sample_metadata) }
            Dir.chdir(cookbooks_path) do
              `git init`
              `git add .`
              `git commit -m "Initial commit."`
            end
          end

          context "resolving" do
            let(:repo_path) { tmp_path.join("repo/resolve") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("cookbooks").mkpath
              cheffile = Helpers.strip_heredoc(<<-CHEFFILE)
                #!/usr/bin/env ruby
                cookbook "sample", :git => #{sample_path.to_s.inspect}
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

              it "should not attempt to install the sample cookbok" do
                repo_path.join("cookbooks/sample").should_not exist
              end
            end
          end

          context "installing" do
            let(:repo_path) { tmp_path.join("repo/install") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("cookbooks").mkpath
              cheffile = Helpers.strip_heredoc(<<-CHEFFILE)
                #!/usr/bin/env ruby
                cookbook "sample", :git => #{sample_path.to_s.inspect}
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

              it "should create the directory for the cookbook" do
                repo_path.join("cookbooks/sample").should exist
              end

              it "should copy the cookbook files into the cookbook directory" do
                repo_path.join("cookbooks/sample/metadata.rb").should exist
              end
            end
          end

          context "resolving and and separately installing" do
            let(:repo_path) { tmp_path.join("repo/resolve-install") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("cookbooks").mkpath
              cheffile = Helpers.strip_heredoc(<<-CHEFFILE)
                #!/usr/bin/env ruby
                cookbook "sample", :git => #{sample_path.to_s.inspect}
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

              it "should create the directory for the cookbook" do
                repo_path.join("cookbooks/sample").should exist
              end

              it "should copy the cookbook files into the cookbook directory" do
                repo_path.join("cookbooks/sample/metadata.rb").should exist
              end
            end
          end

          context "resolving, changing, and resolving" do
            let(:repo_path) { tmp_path.join("repo/resolve-update") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("cookbooks").mkpath
              cheffile = Helpers.strip_heredoc(<<-CHEFFILE)
                git #{cookbooks_path.to_s.inspect}
                cookbook "first-sample"
              CHEFFILE
              repo_path.join("Cheffile").open("wb") { |f| f.write(cheffile) }
              Action::Resolve.new(env).run

              cheffile = Helpers.strip_heredoc(<<-CHEFFILE)
                git #{cookbooks_path.to_s.inspect}
                cookbook "first-sample"
                cookbook "second-sample"
              CHEFFILE
              repo_path.join("Cheffile").open("wb") { |f| f.write(cheffile) }
            end

            context "the second resolve" do
              it "should not raise an exception" do
                expect { Action::Resolve.new(env).run }.to_not raise_error
              end
            end
          end

        end

        context "with a path" do

          let(:git_path) { tmp_path.join("big-git-repo") }
          let(:sample_path) { git_path.join("buttercup") }
          let(:sample_metadata) do
            Helpers.strip_heredoc(<<-METADATA)
              version "0.6.5"
            METADATA
          end

          before :all do
            git_path.rmtree if git_path.exist?
            git_path.mkpath
            sample_path.mkpath
            sample_path.join("metadata.rb").open("wb") { |f| f.write(sample_metadata) }
            Dir.chdir(git_path) do
              `git init`
              `git add .`
              `git commit -m "Initial commit."`
            end
          end

          context "if no path option is given" do
            let(:repo_path) { tmp_path.join("repo/resolve") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("cookbooks").mkpath
              cheffile = Helpers.strip_heredoc(<<-CHEFFILE)
                #!/usr/bin/env ruby
                cookbook "sample",
                  :git => #{git_path.to_s.inspect}
              CHEFFILE
              repo_path.join("Cheffile").open("wb") { |f| f.write(cheffile) }
            end

            it "should not resolve" do
              expect{ Action::Resolve.new(env).run }.to raise_error
            end
          end

          context "if the path option is wrong" do
            let(:repo_path) { tmp_path.join("repo/resolve") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("cookbooks").mkpath
              cheffile = Helpers.strip_heredoc(<<-CHEFFILE)
                #!/usr/bin/env ruby
                cookbook "sample",
                  :git => #{git_path.to_s.inspect},
                  :path => "jelly"
              CHEFFILE
              repo_path.join("Cheffile").open("wb") { |f| f.write(cheffile) }
            end

            it "should not resolve" do
              expect{ Action::Resolve.new(env).run }.to raise_error
            end
          end

          context "if the path option is right" do
            let(:repo_path) { tmp_path.join("repo/resolve") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("cookbooks").mkpath
              cheffile = Helpers.strip_heredoc(<<-CHEFFILE)
                #!/usr/bin/env ruby
                cookbook "sample",
                  :git => #{git_path.to_s.inspect},
                  :path => "buttercup"
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
            end
          end

        end

        context "missing a metadata" do
          let(:git_path) { tmp_path.join("big-git-repo") }
          let(:repo_path) { tmp_path.join("repo/resolve") }
          before do
            repo_path.rmtree if repo_path.exist?
            repo_path.mkpath
            repo_path.join("cookbooks").mkpath
            cheffile = Helpers.strip_heredoc(<<-CHEFFILE)
              cookbook "sample",
                :git => #{git_path.to_s.inspect}
            CHEFFILE
            repo_path.join("Cheffile").open("wb") { |f| f.write(cheffile) }
          end

          context "the resolve" do
            it "should raise an exception" do
              expect { Action::Resolve.new(env).run }.to raise_error
            end

            it "should explain the problem" do
              expect { Action::Resolve.new(env).run }.
                to raise_error(Error, /no metadata file found/i)
            end
          end

          context "the results" do
            before { Action::Resolve.new(env).run rescue nil }

            it "should not create the lockfile" do
              repo_path.join("Cheffile.lock").should_not exist
            end

            it "should not create the directory for the cookbook" do
              repo_path.join("cookbooks/sample").should_not exist
            end
          end
        end

        context "when upstream updates" do
          let(:git_path) { tmp_path.join("upstream-updates-repo") }
          let(:repo_path) { tmp_path.join("repo/resolve-with-upstream-updates") }

          let(:sample_metadata) do
            Helpers.strip_heredoc(<<-METADATA)
              version "0.6.5"
            METADATA
          end
          before do

            # set up the git repo as normal, but let's also set up a release-stable branch
            # from which our Cheffile will only pull stable releases
            git_path.rmtree if git_path.exist?
            git_path.mkpath
            git_path.join("metadata.rb").open("w+b"){|f| f.write(sample_metadata)}

            Dir.chdir(git_path) do
              `git init`
              `git add metadata.rb`
              `git commit -m "Initial Commit."`
              `git checkout -b some-branch --quiet`
              `echo 'hi' > some-file`
              `git add some-file`
              `git commit -m 'Some File.'`
              `git checkout master --quiet`
            end

            # set up the chef repo as normal, except the Cheffile points to the release-stable
            # branch - we expect when the upstream copy of that branch is changed, then we can
            # fetch & merge those changes when we update
            repo_path.rmtree if repo_path.exist?
            repo_path.mkpath
            repo_path.join("cookbooks").mkpath
            cheffile = Helpers.strip_heredoc(<<-CHEFFILE)
              cookbook "sample",
                :git => #{git_path.to_s.inspect},
                :ref => "some-branch"
            CHEFFILE
            repo_path.join("Cheffile").open("wb") { |f| f.write(cheffile) }
            Action::Resolve.new(env).run

            # change the upstream copy of that branch: we expect to be able to pull the latest
            # when we re-resolve
            Dir.chdir(git_path) do
              `git checkout some-branch --quiet`
              `echo 'ho' > some-other-file`
              `git add some-other-file`
              `git commit -m 'Some Other File.'`
              `git checkout master --quiet`
            end
          end

          let(:metadata_file) { repo_path.join("cookbooks/sample/metadata.rb") }
          let(:old_code_file) { repo_path.join("cookbooks/sample/some-file") }
          let(:new_code_file) { repo_path.join("cookbooks/sample/some-other-file") }

          context "when updating not a cookbook from that source" do
            before do
              Action::Update.new(env).run
            end

            it "should pull the tip from upstream" do
              Action::Install.new(env).run

              metadata_file.should exist #sanity
              old_code_file.should exist #sanity

              new_code_file.should_not exist # the assertion
            end
          end

          context "when updating a cookbook from that source" do
            before do
              Action::Update.new(env, :names => %w(sample)).run
            end

            it "should pull the tip from upstream" do
              Action::Install.new(env).run

              metadata_file.should exist #sanity
              old_code_file.should exist #sanity

              new_code_file.should exist # the assertion
            end
          end
        end

      end
    end
  end
end
