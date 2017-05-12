require "shift/api/core/formatters/logger"
module Shift
  module Api
    module Core
      module Middleware
        #
        # Faraday middleware to log requests and responses with request ids
        # to a given logger.
        # The logger must support the "info" method such as active support logger
        #
        class Logger < ::Faraday::Middleware
          def initialize(app, logger:, id_generator: ::Shift::Api::Core::RequestId, formatter: ::Shift::Api::Core::Formatters::Logger)
            self.app = app
            self.logger = logger
            self.id_generator = id_generator
            self.formatter = formatter
          end

          # Logs the request and response to the logger
          # @param [Faraday::Env] env The environment from faraday
          def call(env)
            request_id = id_generator.call
            logger.info formatter.message_from_request_body(env, request_id)
            app.call(env).on_complete do |env|
              logger.info formatter.message_from_response_body(env, request_id)
            end
          end

          private

          attr_accessor :app, :logger, :id_generator, :formatter
        end
      end
    end
  end
end
