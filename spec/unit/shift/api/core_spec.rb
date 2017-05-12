require "spec_helper"

RSpec.describe Shift::Api::Core do

  before(:each) do
    # As the instance is cached, lets always start with nothing
    Shift::Api::Core.root_thread_vars.delete(:config_instance)
  end

  it "has a version number" do
    expect(Shift::Api::Core::VERSION).not_to be nil
  end

  describe "#config" do
    let!(:config_class) { class_double(Shift::Api::Core::Config).as_stubbed_const }
    let(:config_instance) { instance_spy(Shift::Api::Core::Config) }
    it "should request that the configuration is done by a new cached instance of the config when a block is given" do
      expect(config_class).to receive(:new).and_return config_instance
      Shift::Api::Core.config do |config|
        :the_correct_block
      end
      expect(config_instance).to have_received(:batch_configure) do |&block|
        expect(block.call).to eql :the_correct_block
      end
    end

    it "Should return the instance if no block is given" do
      expect(config_class).to receive(:new).and_return config_instance
      expect(Shift::Api::Core.config).to be config_instance
    end
  end
end
