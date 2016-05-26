class ChangeVolumeToShopProduct < ActiveRecord::Migration
  def change
    change_column :shop_products, :stock_volume, :integer, default: 0
    change_column :shop_products, :sales_volume, :integer, default: 0
  end
end
