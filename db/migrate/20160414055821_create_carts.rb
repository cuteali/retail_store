class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.references :shopper
      t.references :shop_product
      t.integer :product_num
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :carts, :shopper_id
    add_index :carts, :shop_product_id
  end
end
