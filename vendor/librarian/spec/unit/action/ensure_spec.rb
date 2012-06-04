require "tmpdir"

require "librarian/error"
require "librarian/action/ensure"

module Librarian
  describe Action::Ensure do

    let(:env) { mock }
    let(:action) { described_class.new(env) }

    before do
      env.stub(:specfile_name) { "Specfile" }
    end

    describe "#run" do

      context "when the environment does not know its project path" do
        before { env.stub(:project_path) { nil } }

        it "should raise an error describing that the specfile is mising" do
          expect { action.run }.to raise_error(Error, "Cannot find Specfile!")
        end
      end

      context "when the environment knows its project path" do
        before { env.stub(:project_path) { Dir.tmpdir } }

        it "should not raise an error" do
          expect { action.run }.to_not raise_error
        end
      end

    end

  end
end
