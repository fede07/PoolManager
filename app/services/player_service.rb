class PlayerService
  def self.get_player_by_auth0_id(auth0_id)
    player = PlayerRepository.find_by_auth0_id(auth0_id)
    if player.nil?
      return { success: false, status: :not_found, message: "Player not found" }
    end
    { success: true, status: :ok, player: player }
  end

  def self.search_players(player_name)
    result = PlayerRepository.all_players(player_name)
    { success: true, status: :ok, players: result }
  end

  def self.create_player(params)
    player = PlayerRepository.find_by_auth0_id(params[:auth0_id])
    if player
      return { success: false, status: :conflict, message: "Player already exists" }
    end
    new_player = PlayerRepository.create(params)
    if new_player
      { success: true, status: :created, player: new_player }
    else
      { success: false, status: :bad_request, errors: new_player.errors.full_messages }
    end
  end

  def self.update_player(player_id, updated_params)
    player = PlayerRepository.find_by_id(player_id)
    if player.nil?
      return { success: false, status: :not_found, message: "Player not found" }
    end
    player.assign_attributes(updated_params)
    PlayerRepository.update(player)
    { success: true, status: :ok, player: player }
  end

  def self.update_player_me(auth0_id, updated_params)
    Rails.logger.info("auth0_id:")
    Rails.logger.info(auth0_id)
    player = PlayerRepository.find_by_auth0_id(auth0_id)
    if player.nil?
      return { success: false, status: :not_found, message: "Player not found" }
    end
    player.assign_attributes(updated_params)
    PlayerRepository.update(player)
    { success: true, status: :ok, player: player }
  end

  def self.delete_player(player_id)
    player = PlayerRepository.find_by_id(player_id)
    if player.nil?
      return { success: false, status: :not_found, message: "Player not found" }
    end
    PlayerRepository.destroy(player)
    { success: true, status: :ok }
  end
end
