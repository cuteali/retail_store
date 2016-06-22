class AddPrepayIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :pay_type, :integer, limit: 1, after: :order_type
    add_column :orders, :prepay_id, :string, after: :pay_type
    add_column :orders, :nonce_str, :string, after: :prepay_id
  end
end
