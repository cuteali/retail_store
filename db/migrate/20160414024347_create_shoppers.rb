class CreateShoppers < ActiveRecord::Migration
  def change
    create_table :shoppers do |t|
      t.string :name
      t.string :phone
      t.string :token
      t.string :key
      t.integer :level, limit: 1, null: false, default: 0
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :shoppers, :name
    add_index :shoppers, :phone
    add_index :shoppers, :token
  end
end
