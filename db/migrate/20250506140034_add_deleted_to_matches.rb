class AddDeletedToMatches < ActiveRecord::Migration[8.0]
  def change
    add_column :matches, :deleted, :boolean, default: false
  end
end
