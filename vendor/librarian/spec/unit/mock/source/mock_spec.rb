require "librarian/mock"

module Librarian
  module Mock
    module Source
      describe Mock do

        let(:env) { Librarian::Mock::Environment.new }

        describe ".new" do

          let(:source) { described_class.new(env, "source-a", {}) }
          subject { source }

          its(:environment) { should_not be_nil }

        end

      end
    end
  end
end
