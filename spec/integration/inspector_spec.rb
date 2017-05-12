require "spec_helper"
#
# Inspector Integration Spec
#
# The purpose of this spec is to prove that the gem is capable of passing
# requests and responses to custom handlers for things like recording.
# It is not to test lots of variations or error conditions etc,,
# The latter being the role of the unit tests
RSpec.describe "inspector integration" do
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
      config.before_request before_request_handler
      config.after_response after_response_handler
    end
  end

  let(:before_request_handler) { instance_spy("Before Request Handler") }
  let(:after_response_handler) { instance_spy("After Response Handler") }

  class User < Shift::Api::Core::Model

  end

  it "should pass the request env on to the before request handler" do
    # Here we must expect before hand as the object that is passed to both
    # handlers is actually the same, just at different life cycle stages
    expect(before_request_handler).to receive(:call).with(an_object_having_attributes(body: a_string_matching(/Shift User/)))
    user = User.create(name: "Shift User")
    expect(stub).to have_been_requested
  end

  it "should pass the request env and response env  on to the after response handler" do
    user = User.create(name: "Shift User")
    expect(stub).to have_been_requested
    expect(after_response_handler).to have_received(:call).with(an_object_having_attributes(body: a_string_matching(/Shift User/)), an_object_having_attributes(body: a_hash_including("data")))

  end
end
