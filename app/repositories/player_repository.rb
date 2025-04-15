class PlayerRepository
  def self.find_by_auth0_id(auth0_id)
    Player.find_by(auth0_id: auth0_id)
  end

  def self.all_players(player_name = nil)
    players = Player.all
    players = players.where("name ILIKE ?", "%#{player_name}%") if player_name.present?
    players
  end

  def self.create(player_attributes)
    Player.create(player_attributes)
  end

  def self.update(player)
    player.save
  end

  def self.destroy(player)
    player.destroy
  end

  def self.find_by_id(id)
    Player.find_by(id: id)
  end
end
