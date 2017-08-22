require "spec_helper"
#
# Token Exchange Integration Spec
#
# The purpose of this spec is to prove that the gem will exchange an api key for a token
# when required before a request is made to the protected resources
RSpec.describe "token exchange integration", type: :api do
  let(:account_reference) { SecureRandom.uuid }
  let(:api_key) { SecureRandom.hex(16) }
  let(:token_exchange_url) { "http://test.com/oauth2/token" }
  before(:each) do
    Shift::Api::Core::Config.new.batch_configure do |config|
      config.shift_root_url = "http://test.com/anyservice/v1"
      config.shift_api_key = api_key
      config.shift_account_reference = account_reference
      config.oauth2_server_url = token_exchange_url
    end
  end

  before(:each) { stub_request(:post, "http://test.com/anyservice/v1/users").to_return(resource_stub_response) }

  let(:resource_stub_response) do
    {
      body: {data: [{id: "1", type: "users", attributes: {name: "Shift User"}}]}.to_json,
      status: 200,
      headers: { "Content-Type": "application/vnd.api+json" }
    }
  end

  let(:token_exchange_response) do
    {
        body: {data: {attributes: {token_type: "Bearer", expires_in: 60, access_token: "aaa"}}}.to_json,
        status: 201,
        headers: { "Content-Type": "application/vnd.api+json" }
    }
  end


  class User < Shift::Api::Core::Model

  end

  it "should exchange the api key for a token and then access the resource" do
    token_exchange_stub = stub_request(:post, token_exchange_url).to_return token_exchange_response
    user = User.create(name: "Shift User")
    expect(a_request(:post, token_exchange_url).with(headers: {"Content-Type" => "application/vnd.api+json", "Accept" => "application/vnd.api+json"})).to have_been_made
    expect(a_request(:post, "http://test.com/anyservice/v1/users").with(headers: {"Authorization": "Bearer aaa"})).to have_been_made
  end
end
