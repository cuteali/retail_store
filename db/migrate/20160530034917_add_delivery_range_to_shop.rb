class AddDeliveryRangeToShop < ActiveRecord::Migration
  def change
    add_column :shops, :delivery_range, :string, after: :is_receiving
  end
end
