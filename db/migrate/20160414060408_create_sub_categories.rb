class CreateSubCategories < ActiveRecord::Migration
  def change
    create_table :sub_categories do |t|
      t.references :category
      t.string :name
      t.integer :sort, null: false, default: 1
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :sub_categories, :category_id
    add_index :sub_categories, :name
  end
end
