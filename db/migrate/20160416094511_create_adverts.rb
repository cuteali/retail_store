class CreateAdverts < ActiveRecord::Migration
  def change
    create_table :adverts do |t|
      t.references :shop
      t.references :shop_product
      t.string :key
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :adverts, :shop_id
    add_index :adverts, :shop_product_id
  end
end
