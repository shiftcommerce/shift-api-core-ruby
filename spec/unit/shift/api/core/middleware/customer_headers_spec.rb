require "spec_helper"
require "shift/api/core/middleware/custom_headers"
module Shift
  module Api
    module Core
      module Middleware
        RSpec.describe CustomHeaders do
          # A Mock app from faradays perspective - similar to a rack app
          let(:mock_app) { instance_spy("Application") }

          # The subject under test - custom_headers_instance
          subject(:custom_headers_instance) { CustomHeaders.new(mock_app, headers: mock_extra_headers) }
          context "with basic hash for headers" do
            let(:mock_extra_headers) { {"Custom": "Headers"} }
            it "should call add the headers to a request coming through the middleware" do
              # Whilst headers should be faraday headers, in this case they behave like a hash
              mock_headers = {"Existing": "Headers"}
              env = instance_double("Faraday::Env", method: :post, url: "http://test.com/v1/users", body: {data: []}.to_json, request_headers: mock_headers)
              custom_headers_instance.call(env)
              expect(mock_app).to have_received(:call).with(env)
              expect(env.request_headers).to include("Custom": "Headers", "Existing": "Headers")
            end
          end

          context "with callable returning hash for headers" do
            let(:mock_extra_headers) { instance_spy("Headers proc", call: { "Custom": "Headers" }) }
            it "should call add the headers to a request coming through the middleware" do
              # Whilst headers should be faraday headers, in this case they behave like a hash
              mock_headers = {"Existing": "Headers"}
              env = instance_double("Faraday::Env", method: :post, url: "http://test.com/v1/users", body: {data: []}.to_json, request_headers: mock_headers)
              custom_headers_instance.call(env)
              expect(mock_extra_headers).to have_received(:call).with(env)
              expect(mock_app).to have_received(:call).with(env)
              expect(env.request_headers).to include("Custom": "Headers", "Existing": "Headers")
            end
          end
        end
      end
    end
  end
end
