class Shopper < ActiveRecord::Base
  mount_uploader :key, AvatarUploader
  
  has_many :addresses
  has_many :carts
  has_many :orders

  enum status: [ :normal, :deleted ]
end
