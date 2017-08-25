require "spec_helper"
require "shift/api/core/model"
RSpec.describe Shift::Api::Core::Model do
  describe "#reconfigure" do
    # 2 mock models which extend the base model - these should be reconfigured
    # when the base model is reconfigured
    let(:mock_model_1) { Class.new(Shift::Api::Core::Model) }
    let(:mock_model_2) { Class.new(Shift::Api::Core::Model) }

    # The config instance.  We cannot use a spy here as rspec complains of
    # it being leaked between tests.  Possibly because it is being passed to
    # sub classes
    let(:config) { Shift::Api::Core::Config.new }

    context "shift_root_url=" do
      it "should set the site with the value of config.shift_root_url" do
        allow(config).to receive(:shift_root_url).and_return("http://correct.com")
        Shift::Api::Core::Model.reconfigure(config)
        expect(Shift::Api::Core::Model.site).to eql "http://correct.com"
      end
    end

    context "adapter=" do
      it "should set the connection options according to the adapter specifed" do
        mock_adapter = [:rack, :some_params]
        allow(config).to receive(:adapter).and_return(mock_adapter)
        Shift::Api::Core::Model.reconfigure(config)
        expect(Shift::Api::Core::Model.connection_options).to include(adapter: mock_adapter)
      end

      it "should not set the connection options if the adapter is :default" do
        Shift::Api::Core::Model.connection_options = {}  # As we cannot rely on a default value as other tests will have changed it
        allow(config).to receive(:adapter).and_return(:default)
        Shift::Api::Core::Model.reconfigure(config)
        expect(Shift::Api::Core::Model.connection_options).not_to include(:adapter)
      end

      it "should not clear the connection options if the adapter is :default and it has been previously set" do
        Shift::Api::Core::Model.connection_options = {adapter: [:rack, :some_options]}  # As we cannot rely on a default value as other tests will have changed it
        allow(config).to receive(:adapter).and_return(:default)
        Shift::Api::Core::Model.reconfigure(config)
        expect(Shift::Api::Core::Model.connection_options).not_to include(:adapter)
      end
    end

    context "#timeout=" do
      it "should set the connection options according to the timeout value specified" do
        timeout_value = 590
        allow(config).to receive(:timeout).and_return(timeout_value)
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        expect(connection.faraday.options.timeout).to eql timeout_value
      end

      it "should set the connection options according to the timeout value specified when it is a numeric string" do
        timeout_value = "590"
        allow(config).to receive(:timeout).and_return(timeout_value)
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        expect(connection.faraday.options.timeout).to eql timeout_value.to_i
      end

      it "should set the connection timeout value to zero when :disabled is used in the config" do
        allow(config).to receive(:timeout).and_return(:disabled)
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        expect(connection.faraday.options.timeout).to equal 0
      end

      it "should set the connection timeout value to zero when 'disabled' is used in the config" do
        allow(config).to receive(:timeout).and_return("disabled")
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        expect(connection.faraday.options.timeout).to equal 0
      end
    end

    context "#open_timeout=" do
      it "should set the connection options according to the open_timeout value specified" do
        timeout_value = 570
        allow(config).to receive(:open_timeout).and_return(timeout_value)
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        expect(connection.faraday.options.open_timeout).to equal timeout_value
      end

      it "should set the connection options according to the open_timeout value specified if its a numeric string" do
        timeout_value = "570"
        allow(config).to receive(:open_timeout).and_return(timeout_value)
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        expect(connection.faraday.options.open_timeout).to equal timeout_value.to_i
      end

      it "should set the connection open_timeout value to zero when :disabled is used in the config" do
        allow(config).to receive(:open_timeout).and_return(:disabled)
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        expect(connection.faraday.options.open_timeout).to equal 0
      end

      it "should set the connection open_timeout value to zero when 'disabled' is used in the config" do
        allow(config).to receive(:open_timeout).and_return("disabled")
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        expect(connection.faraday.options.open_timeout).to equal 0
      end
    end

    context "#headers=" do
      let(:mock_app) { double("An application") }
      let(:mock_headers) { {"Custom": "Header"} }
      let!(:mock_custom_headers_middleware) { class_spy(Shift::Api::Core::Middleware::CustomHeaders).as_stubbed_const  }
      it "should add the custom headers middleware if headers are specified in the config" do
        allow(config).to receive(:headers).and_return(mock_headers)
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        connection.faraday.builder.handlers.find {|h| h == mock_custom_headers_middleware}.build(mock_app)
        expect(mock_custom_headers_middleware).to have_received(:new).with(mock_app, headers: mock_headers)
      end

      it "should add the custom headers middleware even if headers are empty in the config" do
        allow(config).to receive(:headers).and_return({})
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        expect(connection.faraday.builder.handlers).to include mock_custom_headers_middleware
      end

      it "should not remove the custom headers middleware if headers get set to an empty hash in the config" do
        allow(config).to receive(:headers).and_return(mock_headers)
        Shift::Api::Core::Model.reconfigure(config)
        # Load the connection so it is cached
        Shift::Api::Core::Model.connection
        allow(config).to receive(:headers).and_return({})
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        expect(connection.faraday.builder.handlers).to include mock_custom_headers_middleware
      end
    end

    context "logger" do
      let(:mock_logger) { instance_spy("ActiveSupport::Logger") }
      let!(:mock_logger_middleware) { class_spy(Shift::Api::Core::Middleware::Logger).as_stubbed_const }
      let(:mock_app) { double("An application") }
      it "should add the correctly configured logging middleware if the logger is set" do
        Shift::Api::Core::Model.connection_options = {}  # As we cannot rely on a default value as other tests will have changed it
        allow(config).to receive(:logger).and_return(mock_logger)
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        connection.faraday.builder.handlers.find {|h| h == mock_logger_middleware}.build(mock_app)
        expect(mock_logger_middleware).to have_received(:new).with(mock_app, logger: mock_logger)
      end

      it "should not add the logging middleware if the logger is set to :disabled" do
        Shift::Api::Core::Model.connection_options = {}  # As we cannot rely on a default value as other tests will have changed it
        allow(config).to receive(:logger).and_return(:disabled)
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        expect(connection.faraday.builder.handlers).not_to include mock_logger_middleware
      end

      it "should remove the middleware from the connection if the logger gets set to :disabled" do
        Shift::Api::Core::Model.connection_options = {}  # As we cannot rely on a default value as other tests will have changed it
        allow(config).to receive(:logger).and_return(mock_logger)
        Shift::Api::Core::Model.reconfigure(config)
        Shift::Api::Core::Model.connection # Force build the connection as it gets cached
        allow(config).to receive(:logger).and_return(:disabled)
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        expect(connection.faraday.builder.handlers).not_to include mock_logger_middleware
      end
    end

    context "request and response handlers" do
      let(:mock_app) { double("An application") }
      let(:before_request_handlers) { [ -> (_) {:before_handler_1}, -> (_) {:before_handler_2} ] }
      let(:after_response_handlers) { [ -> (_) {:after_handler_1}, -> (_) {:after_handler_2} ] }
      let!(:mock_inspector_middleware) { class_spy(Shift::Api::Core::Middleware::Inspector).as_stubbed_const }
      it "should add the middleware with the handlers if some handlers are present in the config" do
        allow(config).to receive(:before_request_handlers).and_return(before_request_handlers)
        allow(config).to receive(:after_response_handlers).and_return(after_response_handlers)
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        connection.faraday.builder.handlers.find {|h| h == mock_inspector_middleware}.build(mock_app)
        expect(mock_inspector_middleware).
          to have_received(:new).
          with(mock_app, before_request_handlers: before_request_handlers, after_response_handlers: after_response_handlers)
      end

      it "should add the middleware if one set of handlers are not empty but the other set is" do
        allow(config).to receive(:before_request_handlers).and_return(before_request_handlers)
        allow(config).to receive(:after_response_handlers).and_return([])
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        connection.faraday.builder.handlers.find {|h| h == mock_inspector_middleware}.build(mock_app)
        expect(mock_inspector_middleware).
          to have_received(:new).
          with(mock_app, before_request_handlers: before_request_handlers, after_response_handlers: [])

      end

      it "should not add the middleware if both the request and response handlers are empty" do
        allow(config).to receive(:before_request_handlers).and_return([])
        allow(config).to receive(:after_response_handlers).and_return([])
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        expect(connection.faraday.builder.handlers).not_to include(mock_inspector_middleware)
      end

      it "should remove the middleware if the handlers are emptied" do
        allow(config).to receive(:before_request_handlers).and_return(before_request_handlers)
        allow(config).to receive(:after_response_handlers).and_return(after_response_handlers)
        Shift::Api::Core::Model.reconfigure(config)
        # Load the connection so it is cached
        Shift::Api::Core::Model.connection
        allow(config).to receive(:before_request_handlers).and_return([])
        allow(config).to receive(:after_response_handlers).and_return([])
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        expect(connection.faraday.builder.handlers).not_to include(mock_inspector_middleware)
      end
    end

    context "error handling middleware" do
      let!(:mock_error_middleware) { class_spy(Shift::Api::Core::Middleware::ErrorHandler).as_stubbed_const }
      it "should be inserted to be before the status middleware" do
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        handlers = connection.faraday.builder.handlers
        expect(handlers).to include mock_error_middleware
        error_middleware_idx = handlers.index(mock_error_middleware)
        status_middleware_idx = handlers.index(JsonApiClient::Middleware::Status)
        expect(error_middleware_idx).to be < status_middleware_idx
      end
    end

    context "token exchanger middleware" do
      let!(:mock_token_exchanger_middleware) { class_spy(Shift::Api::Core::Middleware::Oauth2TokenExchanger).as_stubbed_const }
      it "should be inserted into the middleware before the custom config middleware" do
        config.shift_api_key="anykey"
        Shift::Api::Core::Model.reconfigure(config)
        connection = Shift::Api::Core::Model.connection
        handlers = connection.faraday.builder.handlers
        expect(handlers).to include mock_token_exchanger_middleware
        token_exchanger_middleware_idx = handlers.index(mock_token_exchanger_middleware)
        config_middleware_idx = handlers.index(Shift::Api::Core::Middleware::CustomHeaders)
        expect(token_exchanger_middleware_idx).to be > config_middleware_idx
      end
    end

    context "reconfigure" do
      it "should inform all subclasses to reconfigure!" do
        allow(mock_model_1).to receive(:reconfigure)
        allow(mock_model_2).to receive(:reconfigure)
        Shift::Api::Core::Model.reconfigure(config)
        expect(mock_model_1).to have_received(:reconfigure).with(config)
        expect(mock_model_2).to have_received(:reconfigure).with(config)
      end

      it "should clear the connection cache for this class" do
        initial_connection = Shift::Api::Core::Model.connection
        allow(config).to receive(:shift_root_url).and_return("http://correct.com")
        Shift::Api::Core::Model.reconfigure(config)
        expect(Shift::Api::Core::Model.connection).not_to be initial_connection
      end
    end
  end
end
