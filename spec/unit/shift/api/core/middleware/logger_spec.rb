require "spec_helper"
module Shift
  module Api
    module Core
      module Middleware
        RSpec.describe Logger do
          # A mock logger so we can see what gets called
          let(:mock_logger) { instance_spy("ActiveSupport::Logger") }
          # A Mock app from faradays perspective - similar to a rack app
          let(:mock_app) { instance_spy("Application") }
          # We use request id 5 throughout all tests here as we are not testing
          # with the global request id generator else we would have to keep
          # resetting it
          let(:mock_request_id) { 5 }

          # Setup the logger to use a simple id generator instead of the global one
          subject(:logger) { Logger.new(mock_app, logger: mock_logger, id_generator: -> () { mock_request_id }) }

          it "should call the logger when data comes through the middleware" do
            env = instance_double("Faraday::Env", body: {data: []}.to_json, method: :post, url: URI.parse("http://test.com/v1/users"))
            logger.call(env)
            expect(mock_app).to have_received(:call).with(env)
            expected_message = "Shift Request (#{mock_request_id}): POST to http://test.com/v1/users with body \"#{{data: []}.to_json}\""
            expect(mock_logger).to have_received(:info).with(expected_message)
          end

          it "should call the logger when data back from the server through the middleware" do
            env = instance_double("Faraday::Env", body: {data: []}.to_json, method: :post, url: URI.parse("http://test.com/v1/users"))
            response_block = nil
            expect(env).to receive(:[]).with(:raw_body).and_return({data: [{id: "1", type: "users", attributes: {name: "Shift User"}}]}.to_json)
            expect(mock_app).to receive(:on_complete) do |&block|
              response_block = block
            end
            logger.call(env)
            expect(mock_app).to have_received(:call).with(env)
            response_block.call(env)
            expected_message = "Shift Response (#{mock_request_id}): #{{data: [{id: "1", type: "users", attributes: {name: "Shift User"}}]}.to_json}"
            expect(mock_logger).to have_received(:info).with(expected_message)
          end
        end
      end
    end
  end
end
