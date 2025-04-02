class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.string :auth0_id, null: false
      t.string :name, null: false
      t.integer :ranking, default: 0
      t.string :preferred_cue
      t.string :profile_picture_url, null: false, default: ""
      t.timestamps
    end
    add_index :players, :auth0_id, unique: true
  end
end
