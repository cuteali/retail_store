class AddClientIdToShopper < ActiveRecord::Migration
  def change
    add_column :shoppers, :client_id, :string, after: :level
  end
end
