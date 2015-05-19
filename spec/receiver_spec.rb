require 'spec_helper'

describe 'Librarian::Puppet::Dsl::Receiver' do

  let(:dsl) { Librarian::Puppet::Dsl.new({}) }
  let(:target) { Librarian::Dsl::Target.new(dsl) }
  let(:receiver) { Librarian::Puppet::Dsl::Receiver.new(target) }

  describe '#run' do

    it 'should get working_dir from pwd when specfile is nil' do
      receiver.run(nil) {}
      expect(receiver.working_path).to eq(Pathname.new(Dir.pwd))
    end

    it 'should get working_dir from pwd with default specfile' do
      receiver.run(dsl.default_specfile) {}
      expect(receiver.working_path).to eq(Pathname.new(Dir.pwd))
    end

    it 'should get working_dir from given path' do
      receiver.run(Pathname.new('/tmp/tmp_module/Puppetfile')) {}
      expect(receiver.working_path).to eq(Pathname.new('/tmp/tmp_module'))
    end
  end
end
