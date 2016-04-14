class Order < ActiveRecord::Base
  belongs_to :address
  belongs_to :shopper
  has_many :orders_shop_products, dependent: :destroy
  has_many :shop_products, through: :orders_shop_products
  accepts_nested_attributes_for :orders_shop_products, allow_destroy: true

  validates :order_no, uniqueness: true

  enum status: [ :normal, :deleted ]
end
