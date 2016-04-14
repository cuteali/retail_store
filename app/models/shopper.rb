class Shopper < ActiveRecord::Base
  has_many :addresses
  has_many :carts
  has_many :orders

  enum status: [ :normal, :deleted ]
end
