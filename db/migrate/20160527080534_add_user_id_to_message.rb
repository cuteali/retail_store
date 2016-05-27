class AddUserIdToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :user_id, :integer, after: :id
    add_index :messages, :user_id
  end
end
