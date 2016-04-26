class AddLnglatToShop < ActiveRecord::Migration
  def change
    remove_column :shops, :position
    add_column :shops, :lng, :string, after: :address
    add_column :shops, :lat, :string, after: :address
  end
end
