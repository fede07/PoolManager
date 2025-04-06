# frozen_string_literal: true

require "jwt"
require "net/http"

# Auth0Client class to handle JWT token validation
class Auth0Client
  # Auth0 Client Objects
  class Response
    attr_accessor :decoded_token, :error
    def initialize(decoded_token, error)
      @decoded_token = decoded_token
      @error = error
    end
  end

  class Error
    attr_accessor :message, :status

    def initialize(message, status)
      @message = message
      @status = status
    end
  end

  class Token
    attr_accessor :token

    def initialize(token)
      @token = token
    end

    def validate_permissions(permissions)
      required_permissions = Set.new permissions
      scopes = token[0]["scope"]
      token_permissions =
        if token[0]["permissions"].present?
          Set.new(token[0]["permissions"])
        elsif token[0]["scope"].present?
          Set.new(token[0]["scope"].split(" "))
        else
          Set.new
        end
      required_permissions <= token_permissions
    end
  end
  # Helper Functions
  def self.domain_url
    "https://#{AUTH0_CONFIG[:domain]}/"
  end

  def self.decode_token(token, jwks_hash)
    JWT.decode(token, nil, true, {
      algorithm: "RS256",
      iss: domain_url,
      verify_iss: true,
      aud: AUTH0_CONFIG[:audience],
      verify_aud: true,
      jwks: { keys: jwks_hash[:keys] }
    })
  end

  def self.get_jwks
    jwks_uri = URI("#{domain_url}.well-known/jwks.json")
    Net::HTTP.get_response jwks_uri
  end

  # Token Validation
  def self.validate_token(token)
    jwks_response = get_jwks

    unless jwks_response.is_a? Net::HTTPSuccess
      error = Error.new("Unable to verify credentials", status: :internal_server_error)
      return Response.new(nil, error)
    end

    jwks_hash = JSON.parse(jwks_response.body).deep_symbolize_keys

    decoded_token = decode_token(token, jwks_hash)

    Response.new(Token.new(decoded_token), nil)
  rescue JWT::VerificationError, JWT::DecodeError => e
    error = Error.new(e.message, :unauthorized)
    Response.new(nil, error)
  end
end
