require "json_api_client"
require "shift/api/core/middleware/logger"
require "shift/api/core/middleware/custom_headers"
require "shift/api/core/middleware/inspector"
require "shift/api/core/middleware/error_handler"
module Shift
  module Api
    module Core
      # The base class for all shift api models.
      #
      # Defining a new model is as simple as extending this.
      class Model < JsonApiClient::Resource
        # Reconfigures the model and all subclasses
        # this is generally called whenever the client
        # is reconfigured on the fly such as in test and
        # development environments.
        # @param [Shift::Api::Core::Config] config The config instance to use
        def self.reconfigure(config)
          configure_site(config)
          configure_adapter(config)
          remove_connection_cache
          configure_error_handler
          configure_logger(config)
          configure_inspector(config)
          configure_timeout(config)
          configure_open_timeout(config)
          configure_headers(config)
          reconfigure_subclasses(config)
        end

        private

        def self.configure_site(config)
          self.site = config.shift_root_url
        end

        def self.configure_error_handler
          connection.faraday.builder.insert_before(JsonApiClient::Middleware::Status, ::Shift::Api::Core::Middleware::ErrorHandler)
        end

        def self.configure_adapter(config)
          adapter = config.adapter
          if adapter == :default
            connection_options.delete(:adapter)
          else
            connection_options.merge!(adapter: adapter)
          end
        end

        def self.configure_headers(config)
          headers = config.headers
          connection.use(::Shift::Api::Core::Middleware::CustomHeaders, headers: headers) unless headers.empty?
        end

        def self.configure_logger(config)
          logger = config.logger
          connection.use(::Shift::Api::Core::Middleware::Logger, logger: logger) unless logger == :disabled
        end

        def self.configure_inspector(config)
          before_request_handlers = config.before_request_handlers
          after_response_handlers = config.after_response_handlers
          return if before_request_handlers.empty? && after_response_handlers.empty?
          connection.use ::Shift::Api::Core::Middleware::Inspector,
                         before_request_handlers: before_request_handlers,
                         after_response_handlers: after_response_handlers
        end

        def self.configure_timeout(config)
          timeout = config.timeout.to_s
          timeout = "0" if timeout == "disabled"
          connection.faraday.options.merge!(timeout: timeout.to_i) unless timeout == "default"
        end

        def self.configure_open_timeout(config)
          open_timeout = config.open_timeout.to_s
          open_timeout = "0" if open_timeout == "disabled"
          connection.faraday.options.merge!(open_timeout: open_timeout.to_i) unless open_timeout == "default"
        end

        def self.reconfigure_subclasses(config)
          subclasses.each do |klass|
            klass.reconfigure(config)
          end
        end

        def self.remove_connection_cache
          self.connection_object = nil
        end
      end
    end
  end
end
