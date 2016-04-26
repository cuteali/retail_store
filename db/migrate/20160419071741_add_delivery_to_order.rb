class AddDeliveryToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_at, :datetime, after: :status
    add_column :orders, :complete_at, :datetime, after: :delivery_at
  end
end
