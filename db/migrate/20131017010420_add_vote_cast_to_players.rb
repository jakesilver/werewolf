class AddVoteCastToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :vote_cast, :string
  end
end
