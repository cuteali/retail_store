class Advert < ActiveRecord::Base
  mount_uploader :key, AvatarUploader
  
  belongs_to :shop
  belongs_to :shop_product

  scope :sorted, -> { order('shop_id DESC') }

  enum status: [ :normal, :deleted ]
end
