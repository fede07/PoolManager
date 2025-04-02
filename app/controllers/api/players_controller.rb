class Api::PlayersController < ApplicationController
  before_action :authorize

  # GET /players/me
  def me
    render json: current_user
  end

  # GET /api/players
  def index
    @players = Player.all
    @players = @players.where("name LIKE ?", "%#{params[:search]}%") if params[:search].present?
    render json: @players
  end

  # POST /api/players
  def create
    @player = Player.new(player_params)
    if @player.save
      render json: @player, status: :created, location: @player
    else
      render json: @player.errors.full_messages, status: :bad_request
    end
  end

  # DELETE /api/players/:id
  def destroy
    if @player.destroy
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
