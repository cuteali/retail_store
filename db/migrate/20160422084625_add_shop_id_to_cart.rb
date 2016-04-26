class AddShopIdToCart < ActiveRecord::Migration
  def change
    add_column :carts, :shop_id, :integer, after: :id
    add_index :carts, :shop_id
  end
end
