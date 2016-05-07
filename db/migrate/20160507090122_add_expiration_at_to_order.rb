class AddExpirationAtToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :expiration_at, :datetime, after: :complete_at
  end
end
