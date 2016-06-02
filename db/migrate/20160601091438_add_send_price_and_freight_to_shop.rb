class AddSendPriceAndFreightToShop < ActiveRecord::Migration
  def change
    add_column :shops, :send_price, :decimal, default: 0.00, null: false, precision: 12, scale: 2, after: :end_at
    add_column :shops, :freight, :decimal, default: 0.00, null: false, precision: 12, scale: 2, after: :send_price
    add_column :orders, :freight, :decimal, default: 0.00, null: false, precision: 12, scale: 2, after: :total_price
  end
end
