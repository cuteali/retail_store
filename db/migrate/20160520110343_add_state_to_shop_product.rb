class AddStateToShopProduct < ActiveRecord::Migration
  def change
    add_column :shop_products, :state, :integer, limit: 1, null: false, default: 1, after: :is_app_index
  end
end
