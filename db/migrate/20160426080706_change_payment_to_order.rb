class ChangePaymentToOrder < ActiveRecord::Migration
  def change
    rename_column :orders, :payment, :state
    change_column :orders, :state, :string, default: 'opening'
    add_column :orders, :trade_no, :string, after: :order_no

    add_index :orders, :state
    add_index :orders, :trade_no
  end
end
