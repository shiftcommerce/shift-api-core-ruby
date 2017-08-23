module Shift
  module Api
    module Core
      class CreateTokenFromApiKey < Model
        def self.configure_token_exchanger(config)
          # Noop - this prevents this special model from using the token exchanger
        end

        def self.site=(url)
          super(url.nil? ? url : url.gsub(/\/[^\/]*\/v1/, ""))
        end

        def self.table_name
          "oauth2/application_token"
        end

        def self.call(attrs)
          create(attrs)
        end
      end
    end
  end
end
