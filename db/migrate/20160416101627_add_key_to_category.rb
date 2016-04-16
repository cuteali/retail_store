class AddKeyToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :key, :string, after: :name
    add_column :detail_categories, :key, :string, after: :name
  end
end
