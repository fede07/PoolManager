class PlayerService
  def self.get_current_player(auth_token)
    auth0_id = auth_token&.split(" ")&.last
    PlayerRepository.find_by_auth0_id(auth0_id)
  end

  def self.search_players(search_query = nil)
    players = PlayerRepository.all_players
    players = players.where("name LIKE ?", "%#{search_query}%") if search_query.present?
    players
  end

  def self.create_player(params)
    player = Player.new(params)
    PlayerRepository.create(player)
  end

  def self.delete_player(player)
    PlayerRepository.destroy(player)
  end
end
