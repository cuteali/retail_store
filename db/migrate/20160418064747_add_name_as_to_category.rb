class AddNameAsToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :name_as, :string, after: :name
  end
end
