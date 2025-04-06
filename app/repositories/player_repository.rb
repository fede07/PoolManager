class PlayerRepository
  def self.find_by_auth0_id(auth0_id)
    Player.find_by(auth0_id: auth0_id)
  end

  def self.all_players
    Player.all
  end

  def self.create(player)
    Player.create(player)
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
