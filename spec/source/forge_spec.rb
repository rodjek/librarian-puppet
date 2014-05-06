require "librarian/puppet/source/forge"
require "librarian/puppet/environment"

include Librarian::Puppet::Source

describe Forge do

  let(:environment) { Librarian::Puppet::Environment.new }
  let(:uri) { "https://forge.puppetlabs.com" }
  subject { Forge.new(environment, uri) }

  before do
    Librarian::Puppet.should_receive(:puppet_version).at_least(1).and_return(puppet_version)
    Librarian::Puppet.should_receive(:puppet_gem_version).at_least(1).and_return(Gem::Version.create(puppet_version.split(' ').first.strip.gsub('-', '.')))
  end

  describe "#check_puppet_module_options" do
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
        let(:puppet_version) { "3.6.0" }
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
