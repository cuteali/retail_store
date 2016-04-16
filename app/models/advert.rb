class Advert < ActiveRecord::Base
  belongs_to :shop
  belongs_to :shop_product

  enum status: [ :normal, :deleted ]
end
