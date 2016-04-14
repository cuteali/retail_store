class CreateDetailCategories < ActiveRecord::Migration
  def change
    create_table :detail_categories do |t|
      t.references :category
      t.references :sub_category
      t.string :name
      t.integer :sort, null: false, default: 1
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :detail_categories, :category_id
    add_index :detail_categories, :sub_category_id
    add_index :detail_categories, :name
  end
end
