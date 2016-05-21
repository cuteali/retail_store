class AddClientTypeToShopper < ActiveRecord::Migration
  def change
    add_column :shoppers, :client_type, :string, after: :client_id
  end
end
