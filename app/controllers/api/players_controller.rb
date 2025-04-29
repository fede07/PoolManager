class Api::PlayersController < ApplicationController
  before_action :authorize

  # POST /api/players
  def create
    puts "player_params: #{player_params}"
    validate_permissions [ "create:players" ] do
      puts "validating permissions"
      result = PlayerService.create_player(player_params)
      puts "result: #{result}"
      render json: result, status: result[:status]
    end
  end

  # GET /api/players
  def index
    validate_permissions [ "read:players" ] do
      result = PlayerService.search_players(params[:player_name])
      render json: result, status: result[:status]
    end
  end

  # GET /players/me
  def me
    auth0_id = @decoded_token.token[0]["sub"]
    result = PlayerService.get_player_by_auth0_id(auth0_id)
    render json: result, status: result[:status]
  end

  # UPDATE/PUT /players/me/
  def update_me
    auth0_id = @decoded_token.token[0]["sub"]
    result = PlayerService.update_player_me(auth0_id, player_update_params)
    render json: result, status: result[:status]
  end

  # UPDATE/PUT /players/:id
  def update
    validate_permissions [ "update:players" ] do
      result = PlayerService.update_player(params[:id], player_params)
      render json: result, status: result[:status]
    end
  end

  # DELETE /api/players/:id
  def destroy
    validate_permissions [ "delete:players" ] do
      result = PlayerService.delete_player(params[:id])
      render json: result, status: result[:status]
    end
  end

  private
  def player_params
    params.permit(:auth0_id, :name, :ranking, :preferred_cue, :profile_picture_url)
  end

  private
  def player_update_params
    params.permit(:name, :preferred_cue, :profile_picture_url)
  end
end
