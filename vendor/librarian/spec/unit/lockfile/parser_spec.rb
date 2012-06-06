require "librarian/helpers"
require "librarian/lockfile/parser"
require "librarian/mock"

module Librarian
  describe Lockfile::Parser do

    let(:env) { Mock::Environment.new }
    let(:parser) { described_class.new(env) }
    let(:resolution) { parser.parse(lockfile) }

    context "a mock lockfile with one source and no dependencies" do
      let(:lockfile) do
        Helpers.strip_heredoc <<-LOCKFILE
          MOCK
            remote: source-a
            specs:

          DEPENDENCIES

        LOCKFILE
      end

      it "should give an empty list of dependencies" do
        resolution.dependencies.should be_empty
      end

      it "should give an empty list of manifests" do
        resolution.manifests.should be_empty
      end
    end

    context "a mock lockfile with one source and one dependency" do
      let(:lockfile) do
        Helpers.strip_heredoc <<-LOCKFILE
          MOCK
            remote: source-a
            specs:
              jelly (1.3.5)

          DEPENDENCIES
            jelly (!= 1.2.6, ~> 1.1)

        LOCKFILE
      end

      it "should give a list of one dependency" do
        resolution.should have(1).dependencies
      end

      it "should give a dependency with the expected name" do
        dependency = resolution.dependencies.first

        dependency.name.should == "jelly"
      end

      it "should give a dependency with the expected requirement" do
        dependency = resolution.dependencies.first

        # Note: it must be this order because this order is lexicographically sorted.
        dependency.requirement.to_s.should == "!= 1.2.6, ~> 1.1"
      end

      it "should give a dependency wth the expected source" do
        dependency = resolution.dependencies.first
        source = dependency.source

        source.name.should == "source-a"
      end

      it "should give a list of one manifest" do
        resolution.should have(1).manifests
      end

      it "should give a manifest with the expected name" do
        manifest = resolution.manifests.first

        manifest.name.should == "jelly"
      end

      it "should give a manifest with the expected version" do
        manifest = resolution.manifests.first

        manifest.version.to_s.should == "1.3.5"
      end

      it "should give a manifest with no dependencies" do
        manifest = resolution.manifests.first

        manifest.dependencies.should be_empty
      end

      it "should give a manifest with the expected source" do
        manifest = resolution.manifests.first
        source = manifest.source

        source.name.should == "source-a"
      end

      it "should give the dependency and the manifest the same source instance" do
        dependency = resolution.dependencies.first
        manifest = resolution.manifests.first

        dependency_source = dependency.source
        manifest_source = manifest.source

        manifest_source.should be dependency_source
      end
    end

    context "a mock lockfile with one source and a complex dependency" do
      let(:lockfile) do
        Helpers.strip_heredoc <<-LOCKFILE
          MOCK
            remote: source-a
            specs:
              butter (2.5.3)
              jelly (1.3.5)
                butter (< 3, >= 1.1)

          DEPENDENCIES
            jelly (!= 1.2.6, ~> 1.1)

        LOCKFILE
      end

      it "should give a list of one dependency" do
        resolution.should have(1).dependencies
      end

      it "should have the expected dependency" do
        dependency = resolution.dependencies.first

        dependency.name.should == "jelly"
      end

      it "should give a list of all the manifests" do
        resolution.should have(2).manifests
      end

      it "should include all the expected manifests" do
        manifests = ManifestSet.new(resolution.manifests)

        manifests.to_hash.keys.should =~ %w(butter jelly)
      end

      it "should have an internally consistent set of manifests" do
        manifests = ManifestSet.new(resolution.manifests)

        manifests.should be_consistent
      end

      it "should have an externally consistent set of manifests" do
        dependencies = resolution.dependencies
        manifests = ManifestSet.new(resolution.manifests)

        manifests.should be_in_compliance_with dependencies
      end
    end

  end
end
