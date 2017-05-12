module Shift
  module Api
    module Core
      # A utility class to generate request id numbers for logging purposes
      class RequestId
        # Generates the next request id
        # @return [Integer] request_id
        def self.call
          thread_vars = Shift::Api::Core.root_thread_vars
          thread_vars[:request_id] ||= 0
          thread_vars[:request_id] += 1
        end

        # Resets the request id back to zero
        def self.reset
          Shift::Api::Core.root_thread_vars[:request_id] = 0
        end
      end
    end
  end
end
