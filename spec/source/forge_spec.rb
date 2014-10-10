require "librarian/puppet/source/forge"
require "librarian/puppet/environment"
require 'librarian/puppet/extension'

include Librarian::Puppet::Source

describe Forge do

  let(:environment) { Librarian::Puppet::Environment.new }
  let(:uri) { "https://forge.puppetlabs.com" }
  let(:puppet_version) { "3.6.0" }
  subject { Forge.new(environment, uri) }

  describe "#manifests" do
    let(:manifests) { [] }
    before do
      expect_any_instance_of(Librarian::Puppet::Source::Forge::RepoV3).to receive(:get_versions).at_least(:once) { manifests }
    end
    it "should return the manifests" do
      expect(subject.manifests("x")).to eq(manifests)
    end
  end

  describe "#check_puppet_module_options" do
    before do
      expect(Librarian::Puppet).to receive(:puppet_version).at_least(:once) { puppet_version }
      expect(Librarian::Puppet).to receive(:puppet_gem_version).at_least(:once) { Gem::Version.create(puppet_version.split(' ').first.strip.gsub('-', '.')) }
    end
    context "Puppet OS" do
      context "3.4.3" do
        let(:puppet_version) { "3.4.3" }
        it { Forge.client_api_version().should == 1 }
      end
      context "2.7.13" do
        let(:puppet_version) { "2.7.13" }
        it { Forge.client_api_version().should == 1 }
      end
      context "3.6.0" do
        it { Forge.client_api_version().should == 3 }
      end
    end
    context "Puppet Enterprise" do
      context "3.2.1" do
        let(:puppet_version) { "3.4.3 (Puppet Enterprise 3.2.1)" }
        it { Forge.client_api_version().should == 3 }
      end
      context "3.1.3" do
        let(:puppet_version) { "3.3.3 (Puppet Enterprise 3.1.3)" }
        it { Forge.client_api_version().should == 1 }
      end
    end
  end
end
