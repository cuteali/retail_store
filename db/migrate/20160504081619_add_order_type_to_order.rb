class AddOrderTypeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :order_type, :integer, limit: 1, null: false, after: :order_no
    remove_index  :orders, :state
    remove_column :orders, :state
    add_column :orders, :state, :string, default: 'opening', after: :total_price
    add_index :orders, :state
  end
end
