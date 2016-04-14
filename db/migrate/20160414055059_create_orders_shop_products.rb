class CreateOrdersShopProducts < ActiveRecord::Migration
  def change
    create_table :orders_shop_products do |t|
      t.references :order
      t.references :shop_product
      t.integer :product_num
      t.decimal :product_price, default: 0.00, null: true, precision: 12, scale: 2
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :orders_shop_products, :order_id
    add_index :orders_shop_products, :shop_product_id
  end
end
