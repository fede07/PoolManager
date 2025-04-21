class Api::AuthController < ApplicationController
  include Secured
  def redirect_to_auth0
    redirect_to auth0_login_url, allow_other_host: true
  end

  # POST auth/register
  def register
    authorize
    result = AuthService.register(@decoded_token, @token)

    if result[:success]
      render json: { message: "Player created successfully", player: result[:player] }, status: result[:status]
    else
      render json: { message: result[:message], errors: result[:errors] }, status: result[:status]
    end
  end

  def callback
    code = params[:code]
    token_response = AuthService.exchange_code_for_token(code)
    if token_response["access_token"]
      render json: { message: "Authenticated successfully", token: token_response }
    else
      render json: { error: "Error authenticating token", details: token_response }, status: :unauthorized
    end
  end

  def logout
    logout_url = auth0_logout_url
    redirect_to logout_url, allow_other_host: true
  end

  private
  def auth0_login_url
    domain = ENV["AUTH0_DOMAIN"]
    client_id = ENV["AUTH0_CLIENT_ID"]
    audience = ENV["AUTH0_AUDIENCE"]
    redirect_uri = ENV["ROOT_URL"] + "/api/auth/callback"
    response_type = "code"
    scope = ""
    nonce = SecureRandom.urlsafe_base64(32)
    state = SecureRandom.urlsafe_base64(32)
    "https://#{domain}/authorize?response_type=#{response_type}&client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{scope}&nonce=#{nonce}&state=#{state}&audience=#{audience}"
  end

  def auth0_logout_url
    domain = ENV["AUTH0_DOMAIN"]
    client_id = ENV["AUTH0_CLIENT_ID"]
    root = ENV["ROOT_URL"]
    "https://#{domain}/v2/logout?client_id=#{client_id}&returnTo=#{root}"
  end
end
