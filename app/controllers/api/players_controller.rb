class Api::PlayersController < ApplicationController
  before_action :authorize

  # POST /api/players
  def create
    validate_permissions [ "create:players" ] do
      player = PlayerService.create_player(player_params)
      if player
        render json: player, status: :created, location: player
      else
        render json: { message: player.errors.full_messages }, status: :bad_request
      end
    end
  end

  # GET /api/players
  def index
    Rails.logger.info(@decoded_token)
    validate_permissions [ "read:players" ] do
      players = PlayerService.search_players(params[:search_query])
      render json: players
    end
  end

  # GET /players/me
  def show
    authorize
    auth0_id = @decoded_token.token[0]["sub"]
    me = PlayerService.get_current_player(auth0_id)
    if me
      render json: me
    else
      render json: { message: "Player not found" }, status: :not_found
    end
  end

  # UPDATE/PUT /players/me
  def update
    auth0_id = @decoded_token.token[0]["sub"]
    player = PlayerService.get_current_player(auth0_id)
    if player
      PlayerService.update_player(player)
    end
  end

  # DELETE /api/players/:id
  def destroy
    if PlayerService.delete_player(params[:id])
      render json: { message: "Player deleted" }, status: :ok
    else
      render json: { message: "Player not found" }, status: :not_found
    end
  end

  private
  def current_user
    auth0_id = request.headers["Authorization"]&.split(" ")&.last
    @current_user ||= Player.find_by(auth0_id: auth0_id)
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:auth0_id, :name, :ranking, :preferred_cue, :profile_picture_url)
  end
end
