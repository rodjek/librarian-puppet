require "librarian/error"
require "librarian/action/install"

module Librarian
  describe Action::Install do

    let(:env) { mock(:specfile_name => "Specfile", :lockfile_name => "Specfile.lock") }
    let(:action) { described_class.new(env) }

    describe "#run" do

      describe "behavior" do

        describe "checking preconditions" do

          context "when the specfile is missing" do
            before do
              env.stub_chain(:specfile_path, :exist?) { false }
            end

            it "should raise an error explaining that the specfile is missing" do
              expect { action.run }.to raise_error(Error, "Specfile missing!")
            end
          end

          context "when the specfile is present but the lockfile is missing" do
            before do
              env.stub_chain(:specfile_path, :exist?) { true }
              env.stub_chain(:lockfile_path, :exist?) { false }
            end

            it "should raise an error explaining that the lockfile is missing" do
              expect { action.run }.to raise_error(Error, "Specfile.lock missing!")
            end
          end

          context "when the specfile and lockfile are present but inconsistent" do
            before do
              env.stub_chain(:specfile_path, :exist?) { true }
              env.stub_chain(:lockfile_path, :exist?) { true }
              action.stub(:spec_consistent_with_lock?) { false }
            end

            it "should raise an error explaining the inconsistenty" do
              expect { action.run }.to raise_error(Error, "Specfile and Specfile.lock are out of sync!")
            end
          end

          context "when the specfile and lockfile are present and consistent" do
            before do
              env.stub_chain(:specfile_path, :exist?) { true }
              env.stub_chain(:lockfile_path, :exist?) { true }
              action.stub(:spec_consistent_with_lock?) { true }
              action.stub(:perform_installation)
            end

            it "should not raise an error" do
              expect { action.run }.to_not raise_error
            end
          end

        end

        describe "performing the install" do

          def mock_manifest(i)
            double(:name => "manifest-#{i}")
          end

          let(:manifests) { 3.times.map{|i| mock_manifest(i)} }
          let(:sorted_manifests) { 4.times.map{|i| mock_manifest(i + 3)} }
          let(:install_path) { mock }

          before do
            env.stub(:install_path) { install_path }
            action.stub(:check_preconditions)
            action.stub_chain(:lock, :manifests) { manifests }
          end

          after do
            action.run
          end

          it "should sort and install the manifests" do
            ManifestSet.should_receive(:sort).with(manifests).exactly(:once).ordered { sorted_manifests }

            install_path.stub(:exist?) { false }
            install_path.should_receive(:mkpath).exactly(:once).ordered

            sorted_manifests.each do |manifest|
              manifest.should_receive(:install!).exactly(:once).ordered
            end
          end

          it "should recreate the install path if it already exists" do
            action.stub(:sorted_manifests) { sorted_manifests }
            action.stub(:install_manifests)

            install_path.stub(:exist?) { true }
            install_path.should_receive(:rmtree)
            install_path.should_receive(:mkpath)
          end

        end

      end

    end

  end
end
