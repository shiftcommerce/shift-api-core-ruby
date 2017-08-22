require "spec_helper"
require "shift/api/core/middleware/oauth2_token_exchanger"
module Shift
  module Api
    module Core
      module Middleware
        RSpec.describe Oauth2TokenExchanger do
          # A shared secret for the JWT tokens
          let(:shared_secret) { SecureRandom.uuid }
          # A Mock app from faradays perspective - similar to a rack app
          let(:mock_app) { instance_spy("Application") }
          # An api key - used throughout
          let(:api_key) { SecureRandom.hex(16) }
          # The account reference - used throughout
          let(:account_reference) { SecureRandom.uuid }
          # The token exchange url - used throughout and its value is not important to this test
          let(:token_exchange_url) { "http://test.com/oauth2/token" }
          let(:client_id) { SecureRandom.uuid }
          let(:client_secret) { SecureRandom.uuid }
          # Mock connection
          let(:mock_create_token_service) { class_double(::Shift::Api::Core::CreateTokenFromApiKey) }

          subject(:token_exchanger_instance) { Oauth2TokenExchanger.new(mock_app, api_key: api_key, account_reference: account_reference, oauth_server_url: token_exchange_url, client_id: client_id, client_secret: client_secret, token_create_service: mock_create_token_service) }

          it "should pass through if the headers already contain a token which has not expired" do
            token = generate_authorization_token(account_reference: account_reference, permissions: {}, shared_secret: shared_secret)
            mock_headers = {"Authorization" => token}.freeze
            env = instance_double("Faraday::Env", method: :get, url: "http://test.com/v1/users", request_headers: mock_headers)
            token_exchanger_instance.call(env)
            expect(mock_app).to have_received(:call).with(env)
            expect(env.request_headers).to include("Authorization" => token)
          end

          it "should request a new token from scratch and call the app if we dont have a token at all" do
            access_token = "anytokendoesntmatter"
            mock_response = double(::Shift::Api::Core::CreateTokenFromApiKey, access_token: access_token, token_type: "Bearer", expires_in: 60)
            expect(mock_create_token_service).to receive(:call).with(client_id: client_id, client_secret: client_secret, scope: "all", api_key: api_key).and_return mock_response
            mock_headers = {}
            env = instance_double("Faraday::Env", method: :get, url: "http://test.com/v1/users", request_headers: mock_headers)
            token_exchanger_instance.call(env)
            expect(mock_app).to have_received(:call).with(env)
            expect(env.request_headers).to include("Authorization" => "Bearer #{access_token}")
          end

          it "should request a new token from the refresh token and call the app if we have a token that is close to expiry"

          it "should request a new token from the refresh token and call the app if we have a token that has expired"

        end
      end
    end
  end
end

