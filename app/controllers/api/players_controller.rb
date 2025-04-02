class Api::PlayersController < ApplicationController
  before_action :authorize

  # GET /players/me
  def me
    render json: PlayerService.get_current_player(request.headers["Authorization"])
  end

  # GET /api/players
  def index
    players = PlayerService.search_players(params[:search_query])
    render json: players
  end

  # POST /api/players
  def create
    player = PlayerService.create_player(player_params)
    if player
      render json: player, status: :created, location: player
    else
      render json: { message: player.errors.full_messages }, status: :bad_request
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
