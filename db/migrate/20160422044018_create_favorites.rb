class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.references :shop
      t.references :shopper
      t.references :shop_product
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :favorites, :shop_id
    add_index :favorites, :shopper_id
    add_index :favorites, :shop_product_id
  end
end
