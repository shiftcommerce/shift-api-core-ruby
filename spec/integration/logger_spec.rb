require "spec_helper"
#
# Logger Integration Spec
#
# The purpose of this spec is to prove that the gem is capable of logging to
# a logger.
# It is not to test lots of variations of this - i.e. what happens if
# we dont specify a logger etc..  The latter being the role of the unit tests
RSpec.describe "logger integration" do
  let(:logger_instance) { instance_spy("ActiveSupport::Logger") }
  let!(:stub) { stub_request(:post, "http://test.com/v1/users").to_return(stub_response) }
  let(:stub_response) do
    {
      body: {data: [{id: "1", type: "users", attributes: {name: "Shift User"}}]}.to_json,
      status: 200,
      headers: { "Content-Type": "application/vnd.api+json" }
    }
  end

  let!(:config_instance) do
    Shift::Api::Core::Config.new.batch_configure do |config|
      config.shift_root_url = "http://test.com/v1"
      config.logger = logger_instance
    end
  end

  class User < Shift::Api::Core::Model

  end

  it "should pass the request on to the logger" do
      user = User.create(name: "Shift User")
      expect(stub).to have_been_requested
      expect(logger_instance).to have_received(:info).with(a_string_matching(/Shift User/)).at_least(:once)
  end

  it "should pass the response on to the logger" do
    user = User.create(name: "Shift User")
    expect(stub).to have_been_requested
    expect(logger_instance).to have_received(:info).with(a_string_matching(/"id":"1"/))
  end
end
