class AddLnglatToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :lng, :string, after: :detail
    add_column :addresses, :lat, :string, after: :detail
  end
end
