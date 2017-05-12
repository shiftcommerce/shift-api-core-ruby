require "spec_helper"
#
# Custom Headers Integration Spec
#
# The purpose of this spec is to prove that the gem is capable of adding a
# custom header.
# It is not to test lots of variations of custom headers and what happens if
# we dont specify any etc..  The latter being the role of the unit tests
RSpec.describe "custom headers integration" do
  before(:each) do
    Shift::Api::Core::Config.new.batch_configure do |config|
      config.shift_root_url = "http://test.com/v1"
      config.headers = {
        "Authorization": "aaa",
        "Some-Other-Header": "bbb"
      }
    end
  end

  before(:each) { stub_request(:post, "http://test.com/v1/users").to_return(stub_response) }

  let(:stub_response) do
    {
      body: {data: [{id: "1", type: "users", attributes: {name: "Shift User"}}]}.to_json,
      status: 200,
      headers: { "Content-Type": "application/vnd.api+json" }
    }
  end


  class User < Shift::Api::Core::Model

  end

  it "should pass the headers on to the request" do
    user = User.create(name: "Shift User")
    expect(a_request(:post, "http://test.com/v1/users").with(headers: {"Authorization": "aaa", "Some-Other-Header": "bbb"})).to have_been_made
  end
end
