# app/models/player.rb
class Player < ApplicationRecord
  validates :auth0_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :ranking, numericality: { only_integer: true }, allow_nil: true
  validates :profile_picture_url, presence: true

  has_many :matches_as_player1, class_name: "Match", foreign_key: "player1_id", dependent: :nullify
  has_many :matches_as_player2, class_name: "Match", foreign_key: "player2_id", dependent: :nullify

  default_scope { where(deleted: false) }

  def soft_delete
    update(deleted: true)
  end

  def as_json(options = {})
    super(options.merge(except: [ :deleted ]))
  end
end
