require "librarian/manifest"

describe Librarian::Manifest::Version do

  describe "version comparison" do

    context "when version has only two components" do
      it "creates a new version with only 2 version components" do
        v1 = described_class.new("1.0")
      end
    end

    context "when neither version has pre-release items" do
      it "compares 1.0.0 < 2.0.0" do
        v1 = described_class.new("1.0.0")
        v2 = described_class.new("2.0.0")
        expect(v1 <=> v2).to eq(-1)
      end
      it "compares 2.0.0 < 2.1.0" do
        v1 = described_class.new("2.0.0")
        v2 = described_class.new("2.1.0")
        expect(v1 <=> v2).to eq(-1)
      end
      it "compares 2.1.0 < 2.1.1" do
        v1 = described_class.new("2.1.0")
        v2 = described_class.new("2.1.1")
        expect(v1 <=> v2).to eq(-1)
      end
    end

    context "when versions have pre-release information" do
      it "compares 1.0.0-alpha < 1.0.0-alpha1" do
        v1 = described_class.new("1.0.0-alpha")
        v2 = described_class.new("1.0.0-alpha.1")
        expect(v1 <=> v2).to eq(-1)
      end
      it "compares 1.0.0-alpha.1 < 1.0.0-alpha.beta" do
        v1 = described_class.new("1.0.0-alpha.1")
        v2 = described_class.new("1.0.0-alpha.beta")
        expect(v1 <=> v2).to eq(-1)
      end
      it "compares 1.0.0-alpha.beta < 1.0.0-beta" do
        v1 = described_class.new("1.0.0-alpha.beta")
        v2 = described_class.new("1.0.0-beta")
        expect(v1 <=> v2).to eq(-1)
      end
      it "compares 1.0.0-beta < 1.0.0-beta.2" do
        v1 = described_class.new("1.0.0-beta")
        v2 = described_class.new("1.0.0-beta.2")
        expect(v1 <=> v2).to eq(-1)
      end
      it "compares 1.0.0-beta.2 < 1.0.0-beta.11" do
        v1 = described_class.new("1.0.0-beta.2")
        v2 = described_class.new("1.0.0-beta.11")
        expect(v1 <=> v2).to eq(-1)
      end
      it "compares 1.0.0-beta.11 < 1.0.0-rc.1" do
        v1 = described_class.new("1.0.0-beta.11")
        v2 = described_class.new("1.0.0-rc.1")
        expect(v1 <=> v2).to eq(-1)
      end
      it "compares 1.0.0-rc.1 < 1.0.0" do
        v1 = described_class.new("1.0.0-rc.1")
        v2 = described_class.new("1.0.0")
        expect(v1 <=> v2).to eq(-1)
      end
    end

    context "when an invalid version number is provided" do
      it "raises" do
        expect { described_class.new("invalidversion") }.
            to raise_error(ArgumentError)
      end
    end

    context "when a version is converted to string" do
      it "should be the full semver" do
        version = "1.0.0-beta.11+200.1.2"
        v1 = described_class.new(version)
        expect(v1.to_s).to eq(version)
      end
      it "should be the full gem version" do
        version = "1.0.0.a"
        v1 = described_class.new(version)
        expect(v1.to_s).to eq(version)
      end
      it "should be the two-component version" do
        version = "1.0"
        v1 = described_class.new(version)
        expect(v1.to_s).to eq(version)
      end
    end
  end
end