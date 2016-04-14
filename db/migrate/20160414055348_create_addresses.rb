class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :shopper
      t.string :area
      t.string :detail
      t.string :receive_name
      t.string :receive_phone
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :addresses, :shopper_id
    add_index :addresses, :receive_name
    add_index :addresses, :receive_phone
  end
end
