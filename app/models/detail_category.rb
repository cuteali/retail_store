class DetailCategory < ActiveRecord::Base
  mount_uploader :key, AvatarUploader
  
  belongs_to :shop
  belongs_to :category
  belongs_to :sub_category
  has_many :products, -> { order "products.sort DESC, products.updated_at DESC" }
  has_many :shop_products, -> { order "shop_products.sort DESC, shop_products.updated_at DESC" }

  scope :sorted, -> { order('sort DESC') }
  scope :base_category, -> { where(shop_id: nil) }

  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 1}

  enum status: [ :normal, :deleted ]

  def self.init_sort(shop=nil)
    if shop
      shop.detail_categories.normal.maximum(:sort).to_i + 1
    else
      DetailCategory.base_category.normal.maximum(:sort).to_i + 1
    end
  end
end
