class Api::MatchesController < ApplicationController
  before_action :authorize

  # GET /matches
  def index
    matches = MatchService.get_matches(params)
    render json: matches
  end

  # GET /matches/:id
  def show
    match_id = params[:id]
    match = MatchService.get_match(match_id)
    render json: match
  end

  # POST /matches
  def create
    Rails.logger.info("Creating match")
    Rails.logger.info(match_params)
    result = MatchService.create_match(match_params)
    render json: result
  end

  # PATCH/PUT /matches/:id
  def update
    result = MatchService.update_match(params[:id], match_update_params)
    render json: result
  end

  # DELETE /matches/:id
  def destroy
    result = MatchService.delete_match(params[:id])
    render json: result
  end

  private
  def match_params
    params.permit(:player1_id, :player2_id, :start_time, :end_time, :table_number)
  end

  private
  def match_update_params
    params.permit(:player1_id, :player2_id, :start_time, :end_time, :winner_id, :table_number)
  end
end
