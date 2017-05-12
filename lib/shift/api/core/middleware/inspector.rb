module Shift
  module Api
    module Core
      module Middleware
        #
        # Faraday middleware to add the ability to register to receive the
        # request environment and/or  the response environment from faraday.
        # Useful for recording or even changing requests / responses
        #
        class Inspector < ::Faraday::Middleware
          def initialize(app, before_request_handlers:, after_response_handlers:)
            self.app = app
            self.before_request_handlers = before_request_handlers
            self.after_response_handlers = after_response_handlers
          end

          # Calls the provided handlers before each request and after the response
          # @param [Faraday::Env] env The environment from faraday
          def call(env)
            notify_request_handlers(env)
            request = env.dup
            app.call(env).on_complete do |env|
              notify_response_handlers(request, env)
            end
          end

          private

          def notify_request_handlers(env)
            before_request_handlers.each do |handler|
              handler.call(env)
              request = env.dup
            end
          end

          def notify_response_handlers(request, env)
            after_response_handlers.each do |handler|
              handler.call(request, env)
            end
          end

          attr_accessor :app, :before_request_handlers, :after_response_handlers
        end
      end
    end
  end
end
