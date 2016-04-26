class AddShopIdToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :shop_id, :integer, after: :id
    add_column :sub_categories, :shop_id, :integer, after: :id
    add_column :detail_categories, :shop_id, :integer, after: :id
    add_index :categories, :shop_id
    add_index :sub_categories, :shop_id
    add_index :detail_categories, :shop_id
  end
end
