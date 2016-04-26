class AddDefaultToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :is_default, :boolean, default: false, null: false, after: :receive_phone
    add_column :categories, :is_app_index, :boolean, default: false, null: false, after: :sort
    add_column :shop_products, :is_app_index, :boolean, default: false, null: false, after: :sort
  end
end
