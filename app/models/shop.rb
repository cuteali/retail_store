class Shop < ActiveRecord::Base
  belongs_to :shop_model
  has_many :adverts
  has_many :shop_products, -> { order "shop_products.sort DESC, shop_products.updated_at DESC" }

  enum status: [ :normal, :deleted ]
end
