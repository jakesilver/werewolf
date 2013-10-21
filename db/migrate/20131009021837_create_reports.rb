class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :high_score
      t.integer :game_ID
      t.string :winners
      t.string :most_kills

      t.timestamps
    end
  end
end
