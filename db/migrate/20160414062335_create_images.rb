class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :key
      t.integer :imageable_id
      t.string :imageable_type
      t.integer :sort, null: false, default: 1
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :images, [:imageable_id, :imageable_type], name: 'imageable_index'
  end
end
