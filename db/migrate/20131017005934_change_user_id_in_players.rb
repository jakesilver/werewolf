class ChangeUserIdInPlayers < ActiveRecord::Migration
  def change
    change_column :players, :UserID, :integer
  end
end
