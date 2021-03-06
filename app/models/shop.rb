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
  has_many :orders_shop_products

  scope :latest, -> { order('created_at DESC') }

  enum status: [ :normal, :deleted ]
  enum is_receiving: [ :turn_on, :turn_off ]
  enum init_status: [ :unfinished, :finished ]

  def business_hours
    "#{start_at} - #{end_at}" if start_at && end_at
  end

  def init_status_name
    unfinished? ? '未完成' : '已完成'
  end
end
