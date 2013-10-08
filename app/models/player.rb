class Player < ActiveRecord::Base
  attr_accessible :Alignment, :UserID, :isDead, :lat, :lng
end
