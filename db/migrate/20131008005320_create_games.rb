class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :createdDate
      t.integer :dayNightFreq
      t.boolean :dayORnight

      t.timestamps
    end
  end
end
