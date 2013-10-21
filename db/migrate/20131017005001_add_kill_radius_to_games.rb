class AddKillRadiusToGames < ActiveRecord::Migration
  def change
    add_column :games, :kill_radius, :float
  end
end
