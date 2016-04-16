class ShopProduct < ActiveRecord::Base
  mount_uploader :key, AvatarUploader
  
  belongs_to :shop
  belongs_to :product
  belongs_to :category
  belongs_to :sub_category
  belongs_to :detail_category
  belongs_to :unit
  has_many :images, as: :menuable
  has_many :orders_shop_products
  has_many :carts
  has_many :adverts

  scope :sorted, -> { order('sort DESC') }

  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 1}

  enum status: [ :normal, :deleted, :app_index ]
end
