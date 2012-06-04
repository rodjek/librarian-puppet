require 'librarian/resolver'
require 'librarian/spec_change_set'
require 'librarian/mock'

module Librarian
  describe Resolver do

    let(:env) { Mock::Environment.new }
    let(:resolver) { env.resolver }

    context "a simple specfile" do

      before do
        env.registry :clear => true do
          source 'source-1' do
            spec 'butter', '1.1'
          end
        end
      end

      let(:spec) do
        env.dsl do
          src 'source-1'
          dep 'butter'
        end
      end

      let(:resolution) { resolver.resolve(spec) }

      specify { resolution.should be_correct }

    end

    context "a specfile with a dep from one src depending on a dep from another src" do

      before do
        env.registry :clear => true do
          source 'source-1' do
            spec 'butter', '1.1'
          end
          source 'source-2' do
            spec 'jam', '1.2' do
              dependency 'butter', '>= 1.0'
            end
          end
        end
      end

      let(:spec) do
        env.dsl do
          src 'source-1'
          src 'source-2' do
            dep 'jam'
          end
        end
      end

      let(:resolution) { resolver.resolve(spec) }

      specify { resolution.should be_correct }

    end

    context "a specfile with a dep depending on a nonexistent dep" do

      before do
        env.registry :clear => true do
          source 'source-1' do
            spec 'jam', '1.2' do
              dependency 'butter', '>= 1.0'
            end
          end
        end
      end

      let(:spec) do
        env.dsl do
          src 'source-1'
          dep 'jam'
        end
      end

      let(:resolution) { resolver.resolve(spec) }

      specify { resolution.should_not be_correct }

    end

    context "a specfile with conflicting constraints" do

      before do
        env.registry :clear => true do
          source 'source-1' do
            spec 'butter', '1.0'
            spec 'butter', '1.1'
            spec 'jam', '1.2' do
              dependency 'butter', '1.1'
            end
          end
        end
      end

      let(:spec) do
        env.dsl do
          src 'source-1'
          dep 'butter', '1.0'
          dep 'jam'
        end
      end

      let(:resolution) { resolver.resolve(spec) }

      specify { resolution.should_not be_correct }

    end

    context "updating" do

      it "should not work" do
        env.registry :clear => true do
          source 'source-1' do
            spec 'butter', '1.0'
            spec 'butter', '1.1'
            spec 'jam', '1.2' do
              dependency 'butter'
            end
          end
        end
        first_spec = env.dsl do
          src 'source-1'
          dep 'butter', '1.1'
          dep 'jam'
        end
        first_resolution = resolver.resolve(first_spec)
        first_resolution.should be_correct
        first_manifests = first_resolution.manifests
        first_manifests_index = Hash[first_manifests.map{|m| [m.name, m]}]
        first_manifests_index['butter'].version.to_s.should == '1.1'

        second_spec = env.dsl do
          src 'source-1'
          dep 'butter', '1.0'
          dep 'jam'
        end
        locked_manifests = ManifestSet.deep_strip(first_manifests, ['butter'])
        second_resolution =resolver.resolve(second_spec, locked_manifests)
        second_resolution.should be_correct
        second_manifests = second_resolution.manifests
        second_manifests_index = Hash[second_manifests.map{|m| [m.name, m]}]
        second_manifests_index['butter'].version.to_s.should == '1.0'
      end

    end

    context "a change to the spec" do

      it "should work" do
        env.registry :clear => true do
          source 'source-1' do
            spec 'butter', '1.0'
          end
          source 'source-2' do
            spec 'butter', '1.0'
          end
        end
        spec = env.dsl do
          src 'source-1'
          dep 'butter'
        end
        lock = resolver.resolve(spec)
        lock.should be_correct

        spec = env.dsl do
          src 'source-1'
          dep 'butter', :src => 'source-2'
        end
        changes = SpecChangeSet.new(env, spec, lock)
        changes.should_not be_same
        manifests = ManifestSet.new(changes.analyze).to_hash
        manifests.should_not have_key('butter')
        lock = resolver.resolve(spec, changes.analyze)
        lock.should be_correct
        lock.manifests.map{|m| m.name}.should include('butter')
        manifest = lock.manifests.find{|m| m.name == 'butter'}
        manifest.should_not be_nil
        manifest.source.name.should == 'source-2'
      end

    end

  end
end
