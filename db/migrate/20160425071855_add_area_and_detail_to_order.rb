class AddAreaAndDetailToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :receive_name, :string, after: :address_id
    add_column :orders, :receive_phone, :string, after: :receive_name
    add_column :orders, :area, :string, after: :receive_phone
    add_column :orders, :detail, :string, after: :area
  end
end
