require "librarian/dependency"

describe Librarian::Dependency do

  describe "validations" do

    context "when the name is blank" do
      it "raises" do
        expect { described_class.new("", [], nil) }.
          to raise_error(ArgumentError, %{name ("") must be sensible})
      end
    end

    context "when the name has leading whitespace" do
      it "raises" do
        expect { described_class.new("  the-name", [], nil) }.
          to raise_error(ArgumentError, %{name ("  the-name") must be sensible})
      end
    end

    context "when the name has trailing whitespace" do
      it "raises" do
        expect { described_class.new("the-name  ", [], nil) }.
          to raise_error(ArgumentError, %{name ("the-name  ") must be sensible})
      end
    end

    context "when the name is a single character" do
      it "passes" do
        described_class.new("R", [], nil)
      end
    end

  end

end
