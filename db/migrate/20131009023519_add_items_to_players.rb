class AddItemsToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :nickname, :string
    add_column :players, :score, :integer
    add_column :players, :votes_for, :integer
  end
end
