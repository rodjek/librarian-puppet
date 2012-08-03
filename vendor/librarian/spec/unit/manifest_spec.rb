require "librarian/manifest"

describe Librarian::Manifest do

  describe "validations" do

    context "when the name is blank" do
      it "raises" do
        expect { described_class.new(nil, "") }.
          to raise_error(ArgumentError, %{name ("") must be sensible})
      end
    end

    context "when the name has leading whitespace" do
      it "raises" do
        expect { described_class.new(nil, "  the-name") }.
          to raise_error(ArgumentError, %{name ("  the-name") must be sensible})
      end
    end

    context "when the name has trailing whitespace" do
      it "raises" do
        expect { described_class.new(nil, "the-name  ") }.
          to raise_error(ArgumentError, %{name ("the-name  ") must be sensible})
      end
    end

    context "when the name is a single character" do
      it "passes" do
        described_class.new(nil, "R")
      end
    end

  end

end
