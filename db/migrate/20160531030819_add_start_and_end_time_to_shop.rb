class AddStartAndEndTimeToShop < ActiveRecord::Migration
  def change
    add_column :shops, :start_at, :string, after: :delivery_range
    add_column :shops, :end_at, :string, after: :start_at
    add_column :orders, :remarks, :string, after: :expiration_at
  end
end
