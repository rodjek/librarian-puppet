require "librarian/action/base"

module Librarian
  describe Action::Base do

    let(:env) { mock }
    let(:action) { described_class.new(env) }

    subject { action }

    it { should respond_to :environment }

    it "should have the environment that was assigned to it" do
      action.environment.should be env
    end

  end
end
