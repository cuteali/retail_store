class AddLogoKeyToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :logo_key, :string, after: :key
  end
end
