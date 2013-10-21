class Player < ActiveRecord::Base
  attr_accessible :Alignment, :UserID, :isDead, :lat, :lng, :game_id, :score, :votes_for, :vote_cast, :nickname

  validates :isDead, :presence => true
  validates :lat, :presence => true
  validates :lng, :presence => true
  validates :Alignment, :presence => true
  validates :UserID, :presence => true
  validates :nickname, :presence => true
  validates :game_id, :presence => true
  validates :score, :presence => true
  validates :votes_for, :presence => true
  validates :vote_cast, :presence => true
end
