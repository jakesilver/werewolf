class RemoveCreatedDateFromGames < ActiveRecord::Migration
  def up
    remove_column :games, :createdDate
  end

  def down
    add_column :games, :createdDate, :integer
  end
end
