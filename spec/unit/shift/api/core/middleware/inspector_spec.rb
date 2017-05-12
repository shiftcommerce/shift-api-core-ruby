require "spec_helper"
module Shift
  module Api
  module Core
    module Middleware
      RSpec.describe Inspector do
        # A mock logger so we can see what gets called
        let(:mock_before_handler) { instance_spy("Before request handler") }
        let(:mock_after_handler) { instance_spy("After response handler") }
        # A Mock app from faradays perspective - similar to a rack app
        let(:mock_app) { instance_spy("Application") }

        subject(:inspector_instance) { Inspector.new(mock_app, before_request_handlers: [mock_before_handler], after_response_handlers: [mock_after_handler]) }

        it "should call the before handler when data comes through the middleware" do
          mock_headers = instance_double("Faraday::Headers", to_hash: {})
          env = instance_double("Faraday::Env", method: :post, url: "http://test.com/v1/users", body: {data: []}.to_json, request_headers: mock_headers)
          inspector_instance.call(env)
          expect(mock_app).to have_received(:call).with(env)
          expect(mock_before_handler).to have_received(:call) do |request|
            expect(request).to be(env)
          end
        end

        it "should call the after_response handler when data back from the server through the middleware" do
          mock_headers = instance_double("Faraday::Headers", to_hash: {})
          env = instance_spy("Faraday::Env", method: :post, url: "http://test.com/v1/users", body: {data: []}.to_json, request_headers: mock_headers)
          response_env = instance_double("Faraday::Env", method: :post, status: 200, url: "http://test.com/v1/users", body: {data: [{id: "1", type: "users", attributes: {}}]}, request_headers: mock_headers, response_headers: mock_headers)
          expect(env).to receive(:dup).and_return(env)  # As dup it makes the testing harder and its just to protect from changes

          # Capture the 'response block' and call it after
          response_block = nil
          expect(mock_app).to receive(:on_complete) do |&block|
            response_block = block
          end

          inspector_instance.call(env)
          response_block.call(response_env)
          expect(mock_app).to have_received(:call).with(env)
          expect(mock_after_handler).to have_received(:call) do |request, response|
            aggregate_failures "Validating request parameter" do
              expect(request).to be env
            end
            aggregate_failures "Validating response parameter" do
              expect(response).to be(response_env)
            end
          end
        end
      end
    end
  end
  end
end
