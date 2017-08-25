require 'jwt_bouncer/sign_request'

module JwtBouncerHelpers

  def self.included(spec)
    spec.after do
      clear_authorization_header
    end
  end

  def clear_authorization_header
    set_jwt_bouncer_shared_secret

    Shift::Api::Core.config do |config|
      config.headers = { }
    end
  end

  def generate_authorization_token(account_reference:, permissions:, shared_secret:, expiry: nil, actor: { type: 'user', id: 1, name: 'Jenkins' })
    JwtBouncer::SignRequest.generate_token(
        permissions: permissions,
        actor: actor,
        account_reference: account_reference,
        shared_secret: shared_secret,
        expiry: expiry
    )
  end

  def decode_jwt_token(token, shared_secret:)
    decoded = JwtBouncer::Token.decode(token, shared_secret)
    decoded['permissions'] = JwtBouncer::Permissions.decompress(decoded['permissions'])
    decoded['actor'] = decoded['actor'].with_indifferent_access
    OpenStruct.new(decoded).freeze
  end

  def set_authorization_header(**options)
    clear_authorization_header

    token = generate_authorization_token(**options)

    Shift::Api::Core.config do |config|
      config.headers = { 'Authorization' => "Bearer #{token}" }
    end
  end

  def set_jwt_bouncer_shared_secret
    ENV['JWT_BOUNCER_SHARED_SECRET'] ||= 'Some shared secret'
  end

end

RSpec.configure do |config|

  config.include JwtBouncerHelpers

end
