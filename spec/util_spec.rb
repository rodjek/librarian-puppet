require 'spec_helper'

describe Librarian::Puppet::Util do

  subject { Class.new { include Librarian::Puppet::Util }.new }

  it 'should get organization name' do
    expect(subject.module_name('puppetlabs-xy')).to eq('xy')
  end

  it 'should get organization name when org contains dashes' do
    expect(subject.module_name('puppet-labs-xy')).to eq('xy')
  end
end
