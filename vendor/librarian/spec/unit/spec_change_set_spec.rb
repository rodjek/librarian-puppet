require 'librarian'
require 'librarian/spec_change_set'
require 'librarian/mock'

module Librarian
  describe SpecChangeSet do

    let(:env) { Mock::Environment.new }
    let(:resolver) { env.resolver }

    context "a simple root removal" do

      it "should work" do
        env.registry :clear => true do
          source 'source-1' do
            spec 'butter', '1.0'
            spec 'jam', '1.0'
          end
        end
        spec = env.dsl do
          src 'source-1'
          dep 'butter'
          dep 'jam'
        end
        lock = resolver.resolve(spec)
        lock.should be_correct

        spec = env.dsl do
          src 'source-1'
          dep 'jam'
        end
        changes = described_class.new(env, spec, lock)
        changes.should_not be_same

        manifests = ManifestSet.new(changes.analyze).to_hash
        manifests.should have_key('jam')
        manifests.should_not have_key('butter')
      end

    end

    context "a simple root add" do

      it "should work" do
        env.registry :clear => true do
          source 'source-1' do
            spec 'butter', '1.0'
            spec 'jam', '1.0'
          end
        end
        spec = env.dsl do
          src 'source-1'
          dep 'jam'
        end
        lock = resolver.resolve(spec)
        lock.should be_correct

        spec = env.dsl do
          src 'source-1'
          dep 'butter'
          dep 'jam'
        end
        changes = described_class.new(env, spec, lock)
        changes.should_not be_same
        manifests = ManifestSet.new(changes.analyze).to_hash
        manifests.should have_key('jam')
        manifests.should_not have_key('butter')
      end

    end

    context "a simple root change" do

      context "when the change is consistent" do

        it "should work" do
          env.registry :clear => true do
            source 'source-1' do
              spec 'butter', '1.0'
              spec 'jam', '1.0'
              spec 'jam', '1.1'
            end
          end
          spec = env.dsl do
            src 'source-1'
            dep 'butter'
            dep 'jam', '= 1.1'
          end
          lock = resolver.resolve(spec)
          lock.should be_correct

          spec = env.dsl do
            src 'source-1'
            dep 'butter'
            dep 'jam', '>= 1.0'
          end
          changes = described_class.new(env, spec, lock)
          changes.should_not be_same
          manifests = ManifestSet.new(changes.analyze).to_hash
          manifests.should have_key('butter')
          manifests.should have_key('jam')
        end

      end

      context "when the change is inconsistent" do

        it "should work" do
          env.registry :clear => true do
            source 'source-1' do
              spec 'butter', '1.0'
              spec 'jam', '1.0'
              spec 'jam', '1.1'
            end
          end
          spec = env.dsl do
            src 'source-1'
            dep 'butter'
            dep 'jam', '= 1.0'
          end
          lock = resolver.resolve(spec)
          lock.should be_correct

          spec = env.dsl do
            src 'source-1'
            dep 'butter'
            dep 'jam', '>= 1.1'
          end
          changes = described_class.new(env, spec, lock)
          changes.should_not be_same
          manifests = ManifestSet.new(changes.analyze).to_hash
          manifests.should have_key('butter')
          manifests.should_not have_key('jam')
        end

      end

    end

    context "a simple root source change" do
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
        changes = described_class.new(env, spec, lock)
        changes.should_not be_same
        manifests = ManifestSet.new(changes.analyze).to_hash
        manifests.should_not have_key('butter')
      end
    end

  end
end
