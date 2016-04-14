class OrdersShopProduct < ActiveRecord::Base
  belongs_to :order
  belongs_to :shop_product

  enum status: [ :normal, :deleted ]
end
