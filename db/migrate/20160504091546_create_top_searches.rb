class CreateTopSearches < ActiveRecord::Migration
  def change
    create_table :top_searches do |t|
      t.string :name
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :top_searches, :name
  end
end
