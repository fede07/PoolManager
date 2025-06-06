class MatchRepository
  def self.all_matches
    Match.all
  end

  def self.create(match)
    Match.create(match)
  end

  def self.conflicting_matches(player_id, start_time, end_time)
    conflict = Match.where("player1_id = :player_id OR player2_id = :player_id", player_id: player_id)
                    .where("(start_time <= :end_time AND end_time >= :start_time)", start_time: start_time, end_time: end_time)
    conflict.exists?
  end

  def self.filtered_matches(date: nil, status: nil, player_id: nil)
    matches = Match.all

    if player_id.present?
      matches = matches.where("player1_id = :player_id OR player2_id = :player_id", player_id: player_id)
    end

    if date.present?
      matches = matches.where("start_time BETWEEN ? AND ?", date.beginning_of_day, date.end_of_day)
    end

    if status.present?
      case status
      when "upcoming"
        matches = matches.where("start_time > ?", Time.now)
      when "ongoing"
        matches = matches.where("start_time <= ?", Time.now)
      when "completed"
        matches = matches.where("end_time < ?", Time.now)
      else
        matches
      end
    end
    matches
  end

  def self.get_match(id)
    Match.find_by(id: id)
  end

  def self.update(match_id, updated_params)
    match = Match.find_by(id: match_id)
    return false if match.nil?
    match.assign_attributes(updated_params)
    match.save
  end

  def self.delete(id)
    match = Match.find_by(id: id)
    return false if match.nil?
    match.soft_delete
  end
end
