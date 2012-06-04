require "librarian"

module Librarian
  module Source
    describe Git do

      let(:env) { Environment.new }

      describe "validating options for the specfile" do

        context "with only known options" do
          it "should not raise" do
            expect { described_class.from_spec_args(env, "some://git/repo.git", :ref => "megapatches") }.
              to_not raise_error
          end
        end

        context "with an unknown option" do
          it "should raise" do
            expect { described_class.from_spec_args(env, "some://git/repo.git", :branch => "megapatches") }.
              to raise_error Error, "unrecognized options: branch"
          end
        end

      end

    end
  end
end
