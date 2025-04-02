class Match < ApplicationRecord
  belongs_to :player1, class_name: "Player"
  belongs_to :player2, class_name: "Player"
  belongs_to :winner, class_name: "Player", optional: true

  validates :start_time, presence: true
end
