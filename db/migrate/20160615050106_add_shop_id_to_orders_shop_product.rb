class AddShopIdToOrdersShopProduct < ActiveRecord::Migration
  def change
    add_column :orders_shop_products, :shop_id, :integer, after: :id
    add_index :orders_shop_products, :shop_id
  end
end
