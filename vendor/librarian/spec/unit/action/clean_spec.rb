require "librarian/action/clean"

module Librarian
  describe Action::Clean do

    let(:env) { mock }
    let(:action) { described_class.new(env) }

    before do
      action.stub(:debug)
    end

    describe "#run" do

      describe "behavior" do

        after do
          action.run
        end

        describe "clearing the cache path" do

          before do
            action.stub(:clean_install_path)
          end

          context "when the cache path is missing" do
            before do
              env.stub_chain(:cache_path, :exist?) { false }
            end

            it "should not try to clear the cache path" do
              env.cache_path.should_receive(:rmtree).never
            end
          end

          context "when the cache path is present" do
            before do
              env.stub_chain(:cache_path, :exist?) { true }
            end

            it "should try to clear the cache path" do
              env.cache_path.should_receive(:rmtree).exactly(:once)
            end
          end

        end

        describe "clearing the install path" do

          before do
            action.stub(:clean_cache_path)
          end

          context "when the install path is missing" do
            before do
              env.stub_chain(:install_path, :exist?) { false }
            end

            it "should not try to clear the install path" do
              env.install_path.should_receive(:children).never
            end
          end

          context "when the install path is present" do
            before do
              env.stub_chain(:install_path, :exist?) { true }
            end

            it "should try to clear the install path" do
              children = [mock, mock, mock]
              children.each do |child|
                child.stub(:file?) { false }
              end
              env.stub_chain(:install_path, :children) { children }

              children.each do |child|
                child.should_receive(:rmtree).exactly(:once)
              end
            end

            it "should only try to clear out directories from the install path, not files" do
              children = [mock(:file? => false), mock(:file? => true), mock(:file? => true)]
              env.stub_chain(:install_path, :children) { children }

              children.select(&:file?).each do |child|
                child.should_receive(:rmtree).never
              end
              children.reject(&:file?).each do |child|
                child.should_receive(:rmtree).exactly(:once)
              end
            end
          end

        end

      end

    end

  end
end
