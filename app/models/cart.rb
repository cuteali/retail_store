class Cart < ActiveRecord::Base
  belongs_to :shopper
  belongs_to :shop_product

  enum status: [ :normal, :deleted ]
end
