class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.references :shop_model
      t.string :name
      t.string :address
      t.string :position
      t.string :tel
      t.string :phone
      t.string :director
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :shops, :name
    add_index :shops, :position
    add_index :shops, :phone
    add_index :shops, :director
  end
end
