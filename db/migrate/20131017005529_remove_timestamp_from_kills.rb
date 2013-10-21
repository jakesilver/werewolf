class RemoveTimestampFromKills < ActiveRecord::Migration
  def up
    remove_column :kills, :timestamp
  end

  def down
    add_column :kills, :timestamp, :string
  end
end
