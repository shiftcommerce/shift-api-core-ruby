module Shift
  module Api
    module Core
      module Formatters
        module Logger
          def self.message_from_request_body(env, request_id)
            msg = "Shift Request (#{ request_id }): #{ env.method.to_s.upcase } to #{ env.url }"
            body = env.body
            msg << " with body \"#{ body }\"" unless body.empty?
            msg
          end

          def self.message_from_response_body(env, request_id)
            "Shift Response (#{ request_id }): #{ env[:raw_body] }"
          end
        end
      end
    end
  end
end
