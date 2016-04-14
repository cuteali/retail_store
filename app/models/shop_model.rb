class ShopModel < ActiveRecord::Base
  has_many :shops

  enum status: [ :normal, :deleted ]
end
