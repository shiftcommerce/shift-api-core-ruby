module Shift
  module Api
    module Core
      module Middleware
        #
        # Faraday middleware to add extra headers to the request
        #
        class CustomHeaders < ::Faraday::Middleware
          def initialize(app, headers:)
            self.app = app
            self.headers = headers
          end

          # Adds the custom headers to the passed in environment
          # @param [Faraday::Env] env The environment from faraday
          def call(env)
            extra_headers = headers
            extra_headers = headers.call(env) if headers.respond_to?(:call)
            env.request_headers.merge!(extra_headers)
            app.call(env)
          end

          private

          attr_accessor :app, :headers
        end
      end
    end
  end
end
