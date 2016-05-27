class Shop < ActiveRecord::Base
  belongs_to :shop_model
  has_many :adverts
  has_many :shop_products, -> { order "shop_products.sort DESC, shop_products.created_at DESC" }
  has_many :orders
  has_many :categories, -> { order "categories.sort DESC" }
  has_many :sub_categories, -> { order "sub_categories.sort DESC" }
  has_many :detail_categories, -> { order "detail_categories.sort DESC" }
  has_many :favorites
  has_many :users
  has_many :messages

  scope :latest, -> { order('created_at DESC') }

  enum status: [ :normal, :deleted ]
  enum is_receiving: [ :turn_on, :turn_off ]
end
