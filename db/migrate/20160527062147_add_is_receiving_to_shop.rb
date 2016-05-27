class AddIsReceivingToShop < ActiveRecord::Migration
  def change
    add_column :shops, :is_receiving, :integer, limit: 1, null: false, default: 1, after: :director
  end
end
