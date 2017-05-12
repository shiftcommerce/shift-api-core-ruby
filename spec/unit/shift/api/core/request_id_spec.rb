require "spec_helper"
RSpec.describe Shift::Api::Core::RequestId do
  before(:each) { Shift::Api::Core::RequestId.reset }
  describe "#call" do
    it "should start at 1" do
      expect(Shift::Api::Core::RequestId.call).to eql 1
    end

    it "should advance to 2 when called twice" do
      expect(Shift::Api::Core::RequestId.call).to eql 1
      expect(Shift::Api::Core::RequestId.call).to eql 2
    end
  end
end
