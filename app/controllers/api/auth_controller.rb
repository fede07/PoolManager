class Api::AuthController < ApplicationController
  include Secured
  include ActionController::Cookies
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
    access_token = token_response["access_token"]
    if access_token
      # redirect_url="#{swagger_url}?token=#{access_token}"
      # redirect_to redirect_url, allow_other_host: true
      # render json: { message: "Authenticated successfully", token: token_response }
      html_content = html_content(access_token, swagger_url)
      render html: html_content.html_safe, layout: false, content_type: "text/html"
      # redirect_to swagger_url, allow_other_host: true
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
    scope = "openid profile email"
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

  def swagger_url
    "#{ENV["ROOT_URL"]}/api-docs/index.html"
  end

  def html_content(access_token, swagger_url)
    token_json = access_token.to_json
    url_json = swagger_url.to_json
    <<-HTML
        <!DOCTYPE html>
        <html>
        <head>
          <title>Redirecting...</title>
          <script>
            try {
              // Almacena el token (ya escapado como JSON string) en sessionStorage
              sessionStorage.setItem('swagger_token', #{token_json});
              // Redirige a la página de Swagger UI (URL escapada como JSON string)
              window.location.href = #{url_json};
            } catch (e) {
              console.error("Error during token storage or redirection:", e);
              document.body.innerText = "An error occurred during authentication redirect. Please try again.";
            }
          </script>
        </head>
        <body>
          <p>Processing authentication and redirecting...</p>
        </body>
        </html>
      HTML
  end
end
