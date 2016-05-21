class ShopModel < ActiveRecord::Base
  has_many :shops, dependent: :destroy

  enum status: [ :normal, :deleted ]
end
