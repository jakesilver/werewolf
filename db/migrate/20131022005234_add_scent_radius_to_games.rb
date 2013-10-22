class AddScentRadiusToGames < ActiveRecord::Migration
  def change
    add_column :games, :scent_radius, :float
  end
end
