class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :category
      t.references :sub_category
      t.references :detail_category
      t.references :unit
      t.string :name
      t.decimal :price, default: 0.00, null: true, precision: 12, scale: 2
      t.decimal :old_price, default: 0.00, null: true, precision: 12, scale: 2
      t.string :key
      t.string :desc
      t.string :info
      t.string :spec
      t.integer :sort, null: false, default: 1
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :products, :category_id
    add_index :products, :sub_category_id
    add_index :products, :detail_category_id
    add_index :products, :unit_id
    add_index :products, :name
  end
end
