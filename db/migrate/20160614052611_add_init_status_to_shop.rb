class AddInitStatusToShop < ActiveRecord::Migration
  def change
    add_column :shops, :init_status, :integer, limit: 1, null: false, default: 0, after: :freight
  end
end
