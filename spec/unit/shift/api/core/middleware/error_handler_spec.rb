require "spec_helper"
require "shift/api/core/middleware/error_handler"
module Shift
  module Api
    module Core
      module Middleware
        RSpec.describe ErrorHandler do
          # A Mock app from faradays perspective - similar to a rack app
          let(:mock_app) { instance_spy("Application") }

          # The subject under test - custom_headers_instance
          subject(:error_handler_instance) { ErrorHandler.new(mock_app) }
          context "Not authorized error" do
            it "should re raise as our error" do
              env = instance_double("Faraday::Env", method: :get, url: "http://test.com/v1/users")
              expect(mock_app).to receive(:call).and_raise(JsonApiClient::Errors::NotAuthorized.new(env))
              expect { error_handler_instance.call(env) }.to raise_error(Shift::Api::Core::Errors::NotAuthorized)
            end
          end

          context "Access denied error" do
            it "should re raise as our error" do
              env = instance_double("Faraday::Env", method: :get, url: "http://test.com/v1/users")
              expect(mock_app).to receive(:call).and_raise(JsonApiClient::Errors::AccessDenied.new(env))
              expect { error_handler_instance.call(env) }.to raise_error(Shift::Api::Core::Errors::AccessDenied)
            end
          end

          context "Not found error" do
            it "should re raise as our error" do
              env = instance_double("Faraday::Env", method: :get, url: "http://test.com/v1/users")
              expect(mock_app).to receive(:call).and_raise(JsonApiClient::Errors::NotFound.new("http://test.com/v1/users"))
              expect { error_handler_instance.call(env) }.to raise_error(Shift::Api::Core::Errors::NotFound)
            end
          end

          context "Conflict error" do
            it "should re raise as our error" do
              env = instance_double("Faraday::Env", method: :get, url: "http://test.com/v1/users")
              expect(mock_app).to receive(:call).and_raise(JsonApiClient::Errors::Conflict.new(env))
              expect { error_handler_instance.call(env) }.to raise_error(Shift::Api::Core::Errors::Conflict)
            end
          end

          context "Server error" do
            it "should re raise as our error" do
              env = instance_double("Faraday::Env", method: :get, url: "http://test.com/v1/users")
              expect(mock_app).to receive(:call).and_raise(JsonApiClient::Errors::ServerError.new(env))
              expect { error_handler_instance.call(env) }.to raise_error(Shift::Api::Core::Errors::ServerError)
            end
          end

          context "Unexpected status error" do
            it "should re raise as our error" do
              env = instance_double("Faraday::Env", method: :get, url: "http://test.com/v1/users")
              expect(mock_app).to receive(:call).and_raise(JsonApiClient::Errors::UnexpectedStatus.new(200, "http://www.test.com"))
              expect { error_handler_instance.call(env) }.to raise_error(Shift::Api::Core::Errors::UnexpectedStatus)
            end
          end

        end
      end
    end
  end
end
