class CreateShopProducts < ActiveRecord::Migration
  def change
    create_table :shop_products do |t|
      t.references :shop
      t.references :product
      t.references :category
      t.references :sub_category
      t.references :detail_category
      t.references :unit
      t.string :name
      t.decimal :price, default: 0.00, null: true, precision: 12, scale: 2
      t.decimal :old_price, default: 0.00, null: true, precision: 12, scale: 2
      t.integer :stock_volume
      t.integer :sales_volume
      t.string :key
      t.string :desc
      t.string :info
      t.string :spec
      t.integer :sort, null: false, default: 1
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :shop_products, :shop_id
    add_index :shop_products, :product_id
    add_index :shop_products, :category_id
    add_index :shop_products, :sub_category_id
    add_index :shop_products, :detail_category_id
    add_index :shop_products, :unit_id
    add_index :shop_products, :name
  end
end
