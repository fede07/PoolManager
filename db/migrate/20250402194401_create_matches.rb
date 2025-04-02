class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.references :player1, foreign_key: { to_table: :players }, null: false
      t.references :player2, foreign_key: { to_table: :players }, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.references :winner, foreign_key: { to_table: :players }
      t.integer :table_number

      t.timestamps
    end
  end
end
