class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.integer :sort, null: false, default: 1
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :categories, :name
  end
end
