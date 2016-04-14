class CreateShopModels < ActiveRecord::Migration
  def change
    create_table :shop_models do |t|
      t.string :name
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :shop_models, :name
  end
end
