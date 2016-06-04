class AddShopperDelToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :shopper_del, :integer, limit: 1, null: false, default: 0, after: :state
  end
end
