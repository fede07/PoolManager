class Api::AuthController < ApplicationController
  include Secured

  # POST auth/register
  def register
    authorize
    result = AuthService.register(@decoded_token)

    if result[:success]
      render json: { message: "Player created successfully", player: result[:player] }, status: result[:status]
    else
      render json: { message: result[:message], errors: result[:errors] }, status: result[:status]
    end
  end
end
