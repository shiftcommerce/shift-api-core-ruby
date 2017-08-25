module Shift
  module Api
    module Core
      module Middleware
        #
        # Faraday middleware to exchange an api key for an oauth2 token
        # and store this in the request headers
        #
        class Oauth2TokenExchanger < ::Faraday::Middleware
          def initialize(app, api_key:, account_reference:, oauth_server_url:, client_id:, client_secret:, token_create_service: ::Shift::Api::Core::CreateTokenFromApiKey)
            self.app = app
            self.api_key = api_key
            self.account_reference = account_reference
            self.oauth_server_url = oauth_server_url
            self.token_create_service = token_create_service
            self.client_id = client_id
            self.client_secret = client_secret
          end

          # Fetches new token if required then call app
          # @param [Faraday::Env] env The environment from faraday
          def call(env)
            return app.call(env) if has_valid_token?(env)
            fetch_token(env)
            app.call(env)
          end

          private

          def has_valid_token?(env)
            env.request_headers.key?('Authorization')
          end

          def connection
            @connection ||= connection_class.new(site: oauth_server_url)

          end

          def fetch_token(env)
            token = token_create_service.call client_id: client_id, scope: "all", api_key: api_key
            #response = connection.run :post, "/oauth2/application_token", client_id: client_id, client_secret: client_secret, scope: "all", api_key: api_key
            env.request_headers.merge! "Authorization" => "Bearer #{token.access_token}"
          end

          attr_accessor :app, :api_key, :account_reference, :oauth_server_url, :token_create_service, :client_id, :client_secret
        end
      end
    end
  end
end
