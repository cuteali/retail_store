class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.string :name
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :units, :name
  end
end
