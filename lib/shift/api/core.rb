require "shift/api/core/version"
require "shift/api/core/config"
require "shift/api/core/model"
require "shift/api/core/middleware"
require "shift/api/core/request_id"
require "shift/api/core/errors"
require "shift/api/core/models/create_token_from_api_key"
module Shift
  module Api
    #
    # Shift::Api::Core
    #
    # This gem is intended for "Shift API" gem authors to use.  It provides the
    # base methods etc.. in order to define models.
    #
    module Core
      ROOT_THREAD_VARS = :"shift-api-core"
      # The global configuration object
      # If a block is passed into this method, it is yielded with
      # the config object and all actions are performed from within the
      # block as a batch - any action(s) that then need performing after
      # a reconfigure are done once only.
      def self.config
        return config_instance unless block_given?
        config_instance.batch_configure do |config|
          yield(config)
        end
      end

      # Global storage per thread for the gems to use where required.
      # @return [Hash] A hash which the caller is free to modify at will
      def self.root_thread_vars
        Thread.current[ROOT_THREAD_VARS] ||= {}
      end

      def self.config_instance
        root_thread_vars[:config_instance] ||= Shift::Api::Core::Config.new
      end
    end
  end
end
