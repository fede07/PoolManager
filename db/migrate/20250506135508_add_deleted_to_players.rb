class AddDeletedToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :deleted, :boolean, default: false
  end
end
