module Shift
  module Api
    module Core
      module Middleware
        #
        # Middleware to translate json api client errors to Shift::Api::Core errors
        #
        # This is so as to not expose json api client stuff to the outside world
        #
        class ErrorHandler < Faraday::Middleware
          def initialize(app)
            self.app = app
          end

          # Executes as normal but catches jsonapi client errors and translates them
          # @param [Faraday::Env] env The environment from faraday
          def call(env)
            app.call(env)
          rescue JsonApiClient::Errors::ApiError => ex
            raise ex.class.name.gsub(/^JsonApiClient::/, "Shift::Api::Core::").constantize.from_jsonapi_client(ex)
          end

          private

          attr_accessor :app
        end
      end
    end
  end
end
