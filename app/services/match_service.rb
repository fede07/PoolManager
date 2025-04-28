class MatchService
  DEFAULT_MATCH_DURATION = 90.minutes

  def self.create_match(params)
    Rails.logger.info("Creating match")
    Rails.logger.info(params)

    player1_id = params[:player1_id]
    player2_id = params[:player2_id]

    if player1_id.nil?
      return { success: false, status: :bad_request, message: "Missing player 1" }
    end

    if player2_id.nil?
      return { success: false, status: :bad_request, message: "Missing player 2" }
    end

    if params[:start_time].nil?
      return { success: false, status: :bad_request, message: "Missing start time" }
    end

    begin
      start_time = Time.parse(params[:start_time])
    rescue
      return { success: false, status: :bad_request, message: "Invalid start time" }
    end

    if params[:end_time].present?
      begin
        end_time = Time.parse(params[:end_time])
      rescue
        return { success: false, status: :bad_request, message: "Invalid end time" }
      end
      if end_time < start_time
        return { success: false, status: :bad_request, message: "End time cannot be before start time" }
      end
    else
      end_time = Time.parse(params[:start_time]) + DEFAULT_MATCH_DURATION
    end

    if PlayerRepository.find_by_id(player1_id).nil?
      return { success: false, status: :not_found, message: "Player 1 not found" }
    end

    if PlayerRepository.find_by_id(player2_id).nil?
      return { success: false, status: :not_found, message: "Player 2 not found" }
    end

    if player1_id == player2_id
      return { success: false, status: :bad_request, message: "Player cannot play against themselves" }
    end

    conflict = MatchRepository.conflicting_matches(player1_id, start_time, end_time)
    unless conflict.present?
      (MatchRepository.conflicting_matches(player2_id, start_time, end_time))
    end
    if conflict.present?
      return { success: false, status: :conflict, message: "Double booking not allowed" }
    end
    MatchRepository.create(params)
    { success: true, status: :created }
  end

  def self.get_matches(params)
    player_id = params[:player_id].present? ? params[:player_id] : nil

    date = nil
    if params[:date].present?
      begin
        date = Time.parse(params[:date])
      rescue
        return { success: false, status: :bad_request, message: "Invalid date" }
      end
    end
    status = params[:status].present? ? params[:status] : nil
    if status
      valid_status = %w[upcoming ongoing completed]
      unless valid_status.include?(status)
        return { success: false, status: :bad_request, message: "Invalid status" }
      end
    end
    matches = MatchRepository.filtered_matches(date: date, status: status, player_id: player_id)
    matches
  end

  def self.get_match(id)
    result = MatchRepository.get_match(id)
    if result.nil?
      return { success: false, status: :not_found, message: "Match not found" }
    end
    { success: true, status: :ok, match: result }
  end

  def self.update_match(match_id, update_params)
    match = MatchRepository.get_match(match_id)
    if match.nil?
      return { success: false, status: :not_found, message: "Match not found" }
    end

    player1_id = update_params[:player1_id]
    if update_params[:player1_id]
      player1_id = update_params[:player1_id]
      if PlayerRepository.find_by_id(player1_id).nil?
        return { success: false, status: :not_found, message: "Player 1 not found" }
      end
    end

    if update_params[:player2_id].present?
      player2_id = update_params[:player2_id]
      if PlayerRepository.find_by_id(player2_id).nil?
        return { success: false, status: :not_found, message: "Player 2 not found" }
      end
    end

    if player1_id.present? && player2_id.present? && player1_id == player2_id
      return { success: false, status: :conflict, message: "Player cannot play against themselves" }
    end

    if update_params[:start_time].present?
      begin
        Date.parse(update_params[:start_time])
      rescue
        return { success: false, status: :bad_request, message: "Invalid start time" }
      end
    end

    if update_params[:end_time].present?
      begin
        Time.parse(update_params[:end_time])
      rescue
        return { success: false, status: :bad_request, message: "Invalid end time" }
      end
    end

    if update_params[:winner_id].present?
      winner_id = update_params[:winner_id]
      if PlayerRepository.find_by_id(winner_id).nil?
        return { success: false, status: :not_found, message: "Winner ID not found" }
      end
    end

    MatchRepository.update(match_id, update_params)
    if winner_id.present?
      winner = PlayerRepository.find_by_id(winner_id)
      if winner.nil?
        return { success: false, status: :not_found, message: "Winner not found" }
      end
      winner.update(ranking: winner.ranking + 1)
      PlayerRepository.update(winner)
    end

    { success: true, status: :ok }
  end

  def self.delete_match(match_id)
    match = MatchRepository.get_match(match_id)

    if match.nil?
      return { success: false, status: :not_found, message: "Match not found" }
    end

    if match.start_time < Time.now
      return { success: false, status: :conflict, message: "Match cannot be deleted if already started" }
    end

    MatchRepository.delete(match_id)
    { success: true, status: :ok }
  end
end
