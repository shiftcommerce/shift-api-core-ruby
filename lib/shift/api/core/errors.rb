module Shift
  module Api
    module Core
      # Shift::Api::Core version of the original JsonApiClient Errors
      # purely so we are not exposing jsonapi client exceptions to the outside
      # world in case we ever migrate from it.
      module Errors
        class ApiError < StandardError
          attr_reader :env
          def initialize(env)
            @env = env
          end

          def self.from_jsonapi_client(ex)
            new(ex.env)
          end
        end

        class ClientError < ApiError
        end

        class AccessDenied < ClientError
        end

        class NotAuthorized < ClientError
        end

        class ConnectionError < ApiError
        end

        class ServerError < ApiError
          # Replace message with more useful error from the API
          def message
            default_message = "Internal Server Error"

            api_errors = env.response.body["errors"]
            return default_message if api_errors.nil?

            api_exception = api_errors[0].dig("meta", "exception")
            api_exception ? api_exception : default_message
          end

          # Prepend API backtrace to the backtrace from the gem
          def backtrace
            original_backtrace = super
            return nil if original_backtrace.nil?

            api_errors = env.response.body["errors"]
            return original_backtrace if api_errors.nil?

            api_backtrace = api_errors[0].dig("meta", "backtrace")
            return original_backtrace if api_backtrace.nil?

            api_backtrace.map { |entry| "/<shift_api>#{entry}" }.concat(original_backtrace)
          end
        end

        class Conflict < ServerError
          def message
            "Resource already exists"
          end
        end

        class NotFound < ServerError
          attr_reader :uri
          def initialize(uri)
            @uri = uri
          end

          def message
            "Couldn't find resource at: #{ uri }"
          end

          def self.from_jsonapi_client(ex)
            new(ex.uri)
          end
        end

        class UnexpectedStatus < ServerError
          attr_reader :code, :uri
          def initialize(code, uri)
            @code = code
            @uri = uri
          end

          def message
            "Unexpected response status: #{ code } from: #{ uri }"
          end

          def self.from_jsonapi_client(ex)
            new(ex.code, ex.uri)
          end
        end
      end
    end
  end
end
