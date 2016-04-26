class Advert < ActiveRecord::Base
  mount_uploader :key, AvatarUploader
  
  belongs_to :shop
  belongs_to :shop_product

  enum status: [ :normal, :deleted ]
end
