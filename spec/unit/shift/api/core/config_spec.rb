require "spec_helper"
require "shift/api/core/config"
describe Shift::Api::Core::Config do
  subject(:config_instance) { Shift::Api::Core::Config.new }
  let!(:mock_base_model) { class_spy("Shift::Api::Core::Model").as_stubbed_const }

  describe "#shift_root_url=" do
    it "should request a reconfigure" do
      config_instance.shift_root_url="http://shift_root_url_changed.com"
      expect(mock_base_model).to have_received(:reconfigure).with(subject)
      expect(subject.shift_root_url).to eql "http://shift_root_url_changed.com"
    end
  end

  describe "#logger=" do
    let(:mock_logger) { instance_double("ActiveSupport::Logger") }
    it "should request a reconfigure" do
      config_instance.logger=mock_logger
      expect(mock_base_model).to have_received(:reconfigure).with(subject)
      expect(subject.logger).to be mock_logger
    end
  end

  describe "logger" do
    it "should be :disabled by default" do
      expect(config_instance.logger).to eql :disabled
    end
  end

  describe "#adapter=" do
    let(:mock_adapter) { [:rack, :some_params] }
    it "should request a reconfigure" do
      config_instance.adapter=mock_adapter
      expect(mock_base_model).to have_received(:reconfigure).with(subject)
      expect(subject.adapter).to be mock_adapter
    end
  end

  describe "#timeout=" do
    it "should request a reconfigure" do
      config_instance.timeout = 590
      expect(mock_base_model).to have_received(:reconfigure).with(subject)
      expect(subject.timeout).to eql 590
    end

    it "should have a default value of :default" do
      expect(config_instance.timeout).to eql :default
    end
  end

  describe "#open_timeout=" do
    it "should request a reconfigure" do
      config_instance.open_timeout = 590
      expect(mock_base_model).to have_received(:reconfigure).with(subject)
      expect(subject.open_timeout).to eql 590
    end

    it "should have a default value of :default" do
      expect(config_instance.open_timeout).to eql :default
    end
  end

  describe "#headers" do
    it "should request a reconfigure" do
      config_instance.headers = {key: :value}
      expect(mock_base_model).to have_received(:reconfigure).with(subject)
      expect(subject.headers).to eql(key: :value)
    end

    it "should be empty hash by default" do
      expect(config_instance.headers).to eql({})
    end

    it "should allow modification of the original without changing stored version" do
      headers = {key: :value}
      config_instance.headers = headers
      headers.merge!(unwanted: :key)
      expect(subject.headers).to eql(key: :value)
    end
  end

  describe "shift_api_key=" do
    it "should have a default value of nil" do
      expect(config_instance.shift_api_key).to be_nil
    end

    it "should request a reconfigure" do
      config_instance.shift_api_key = SecureRandom.hex(16)
      expect(mock_base_model).to have_received(:reconfigure).with(subject)
    end

    it "should store the value set" do
      key = SecureRandom.hex(16)
      config_instance.shift_api_key = key
      expect(config_instance.shift_api_key).to eql key
    end
  end

  describe "shift_account_reference=" do
    it "should have a default value of nil" do
      expect(config_instance.shift_account_reference).to be_nil
    end

    it "should request a reconfigure" do
      config_instance.shift_account_reference = SecureRandom.uuid
      expect(mock_base_model).to have_received(:reconfigure).with(subject)
    end

    it "should store the value set" do
      account_reference = SecureRandom.uuid
      config_instance.shift_account_reference = account_reference
      expect(config_instance.shift_account_reference).to eql account_reference
    end
  end

  describe "oauth2_server_url=" do
    it "should have a default value of nil" do
      expect(config_instance.oauth2_server_url).to be_nil
    end

    it "should request a reconfigure" do
      config_instance.oauth2_server_url = "http://test.com"
      expect(mock_base_model).to have_received(:reconfigure).with(subject)
    end

    it "should store the value set" do
      url = "http://test.com"
      config_instance.oauth2_server_url = url
      expect(config_instance.oauth2_server_url).to eql url
    end
  end

  describe "oauth2_client_id=" do
    it "should have a default value of nil" do
      expect(config_instance.oauth2_client_id).to be_nil
    end

    it "should request a reconfigure" do
      config_instance.oauth2_client_id = "clientid"
      expect(mock_base_model).to have_received(:reconfigure).with(subject)
    end

    it "should store the value set" do
      client_id = "clientid"
      config_instance.oauth2_client_id = client_id
      expect(config_instance.oauth2_client_id).to eql client_id
    end
  end

  describe "oauth2_client_secret=" do
    it "should have a default value of nil" do
      expect(config_instance.oauth2_client_secret).to be_nil
    end

    it "should request a reconfigure" do
      config_instance.oauth2_client_secret = "secret"
      expect(mock_base_model).to have_received(:reconfigure).with(subject)
    end

    it "should store the value set" do
      client_secret = "secret"
      config_instance.oauth2_client_secret = client_secret
      expect(config_instance.oauth2_client_secret).to eql client_secret
    end
  end

  describe "#before_request" do
    let(:mock_request_proc) { -> (_) { :noop } }
    it "should request a reconfigure" do
      config_instance.before_request mock_request_proc
      expect(mock_base_model).to have_received(:reconfigure).with(subject)
      expect(subject.before_request_handlers).to include mock_request_proc
    end
  end

  describe "#after_response" do
    let(:mock_response_proc) { -> (_, _) { :noop } }
    it "should request a reconfigure" do
      config_instance.after_response mock_response_proc
      expect(mock_base_model).to have_received(:reconfigure).with(subject)
      expect(subject.after_response_handlers).to include mock_response_proc
    end
  end

  describe "#batch_configure" do
    let(:mock_logger) { instance_double("ActiveSupport::Logger") }
    it "should call reconfigure! only once" do
      config_instance.batch_configure do |config|
        config.shift_root_url="http://shift_root_url_changed.com"
        config.logger = mock_logger
      end
      expect(mock_base_model).to have_received(:reconfigure).with(subject).once
    end
  end
end
