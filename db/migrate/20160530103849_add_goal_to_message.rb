class AddGoalToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :goal, :integer, limit: 1, after: :shop_id
  end
end
