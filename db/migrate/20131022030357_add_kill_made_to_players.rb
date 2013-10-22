class AddKillMadeToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :kill_made, :string
  end
end
