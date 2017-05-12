require "singleton"
module Shift
  module Api
    module Core
      #
      # Global configuration
      #
      #
      # A simple config might look like this:-
      #
      # Shift::Api::Core.config do
      #   config.shift_root_url = ENV["SHIFT_ROOT_URL"]
      #   config.logger = Rails.logger
      #   config.timeout = ENV["SHIFT_TIMEOUT"]
      #   config.open_timeout = ENV["SHIFT_OPEN_TIMEOUT"]
      # end
      #
      #
      #
      # But, for testing, where the test suite wants to see data going both ways,
      # and have no timeouts,
      # we may have something like this :-
      #
      # Shift::Api::Core.config do
      #   config.shift_root_url = test_root_url
      #   config.logger = Rails.logger
      #   config.before_request -> (request) { do_something_with_request }
      #   config.after_response -> (request, response) { do_something_with_request_or_response }
      #   config.adapter = [:rack, application_under_test]
      #   config.timeout = 0
      #   config.open_timeout = 0
      # end
      #
      # See detailed documentation below for more ...

      class Config
        # @!attribute [rw] shift_root_url
        #  The root url for the shift server
        # @!attribute [rw] logger
        #  The logger to use or nil for none.  Must be compatible
        #  with an ActiveSupport logger
        # @!attribute [rw] adapter
        #  The adapter to use for faraday or :default for the default
        # @!attribute [r] before_request_handlers
        #   An array of callable objects (lambda etc..) that are called with
        #   the request before it goes out
        #   defaults to []
        # @!attribute [r] after_response_handlers
        #  An array of callable objects (lambda etc..) that are called with the
        #  request and response after it has been receive from the server
        #  defaults to []
        # @!attribute [rw] headers
        #  Extra headers to add to every request
        #  defaults to {}
        #  Can also be an object responding to :call (i.e. a proc or lambda etc..)
        #  which must return a hash of headers to add
        # @!attribute [rw] timeout
        #  The connection read timeout in seconds.  If data is not received in
        #  this time, an error is raised.
        #  defaults to :default (15 seconds)
        # @!attribute [rw] open_timeout
        #  The connection open timeout in seconds - i.e. if it takes longer than
        #  this to open connection, an error is raised
        #  defaults to :default (15 seconds)
        attr_reader :shift_root_url, :logger, :before_request_handlers, :after_response_handlers, :adapter, :headers, :timeout, :open_timeout

        def initialize
          @before_request_handlers = []
          @after_response_handlers = []
          @allow_reconfigure = true
          @adapter = :default
          @logger = :disabled
          @headers = {}
          @timeout = :default
          @open_timeout = :default
        end

        def shift_root_url=(url)
          @shift_root_url = url.tap { reconfigure }
        end

        def logger=(logger)
          @logger = logger.tap { reconfigure }
        end

        def adapter=(adapter)
          @adapter = adapter.tap { reconfigure }
        end

        def headers=(headers)
          @headers = headers.deep_dup.tap { reconfigure }
        end

        def timeout=(timeout)
          @timeout = timeout.tap { reconfigure }
        end

        def open_timeout=(open_timeout)
          @open_timeout = open_timeout.tap { reconfigure }
        end

        # Registers a handler that is to be called before the request is made
        # to the server.
        # Multiple handlers get called in the sequence they were registered
        # The handlers are called with the request as the parameter
        # @param handler [#call] A handler that responds to call
        def before_request(handler)
          @before_request_handlers << handler
          reconfigure
        end

        # Registers a handler that is to be called after the response is returned
        # from the server.
        # Multiple handlers get called in the sequence they were registered
        # The handlers are called with the request and the response as the parameters
        # @param handler [#call] A handler that responds to call
        def after_response(handler)
          @after_response_handlers << handler
          reconfigure
        end

        # As every change to the config forces all models to reconfigure, this method
        # allows for batch changes where the reconfigure is done at the end of the
        # passed block.
        def batch_configure
          disable_reconfigure
          yield self
        ensure
          enable_reconfigure
          reconfigure
        end

        private

        def disable_reconfigure
          @allow_reconfigure = false
        end

        def enable_reconfigure
          @allow_reconfigure = true
        end

        def reconfigure
          return unless @allow_reconfigure
          Shift::Api::Core::Model.reconfigure(self)
        end
      end
    end
  end
end
