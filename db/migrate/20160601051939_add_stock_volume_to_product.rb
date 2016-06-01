class AddStockVolumeToProduct < ActiveRecord::Migration
  def change
    add_column :products, :is_app_index, :boolean, default: false, null: false, after: :sort
    add_column :products, :state, :integer, limit: 1, null: false, default: 1, after: :is_app_index
    add_column :products, :stock_volume, :integer, null: false, default: 0, after: :state
    add_column :products, :sales_volume, :integer, null: false, default: 0, after: :stock_volume
  end
end
