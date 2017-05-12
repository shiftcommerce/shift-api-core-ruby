require "spec_helper"

#
# Error Handling Integration Spec
#
# The purpose of this spec is to prove that the gem is translating
# a single JsonApiClient exception into the Shift::Api::Core equivalent
# It is not to test lots of different errors
# The latter being the role of the unit tests
RSpec.describe "error handling" do
  context "401 Unauthorized" do
    let!(:stub) { stub_request(:get, "http://test.com/v1/users").to_return(stub_response) }
    let(:stub_response) do
      {
        body: {anything: :goes}.to_json,
        status: 401,
        headers: { "Content-Type": "application/vnd.api+json" }
      }
    end

    let!(:config_instance) do
      Shift::Api::Core::Config.new.batch_configure do |config|
        config.shift_root_url = "http://test.com/v1"
      end
    end

    class User < Shift::Api::Core::Model

    end

    it "should raise the correct error" do
      expect { User.all }.to raise_error(Shift::Api::Core::Errors::NotAuthorized)
    end

  end
end
