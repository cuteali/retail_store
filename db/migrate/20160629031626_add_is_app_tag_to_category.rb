class AddIsAppTagToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :is_app_tag, :boolean, default: false, null: false, after: :is_app_index
  end
end
