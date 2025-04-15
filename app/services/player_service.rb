class PlayerService
  def self.get_player_by_auth0_id(auth_id)
    player = PlayerRepository.find_by_auth0_id(auth_id)
    if player.nil?
      return { success: false, status: :not_found, message: "Player not found" }
    end
    { success: true, status: :ok, player: player }
  end

  def self.search_players(player_name)
    PlayerRepository.all_players(player_name)
  end

  def self.create_player(params)
    player = PlayerRepository.find_by_auth0_id(params[:auth0_id])
    if player
      return { success: false, status: :conflict, message: "Player already exists" }
    end
    new_player = PlayerRepository.create(params)
    { success: true, status: :created, player: new_player }
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
