class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :shopper
      t.references :shop
      t.references :address
      t.string :order_no
      t.decimal :total_price, default: 0.00, null: true, precision: 12, scale: 2
      t.integer :payment, limit: 1, null: false, default: 0
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :orders, :shopper_id
    add_index :orders, :shop_id
    add_index :orders, :address_id
    add_index :orders, :order_no
  end
end
