class Category < ActiveRecord::Base
  mount_uploader :key, AvatarUploader
  mount_uploader :logo_key, AvatarUploader
  
  belongs_to :shop
  has_many :sub_categories
  has_many :detail_categories
  has_many :products, -> { order "products.sort DESC, products.updated_at DESC" }
  has_many :shop_products, -> { order "shop_products.sort DESC, shop_products.updated_at DESC" }

  scope :sorted, -> { order('sort DESC') }
  scope :base_category, -> { where(shop_id: nil) }

  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 1}

  enum status: [ :normal, :deleted ]
  enum is_app_index: { is_index: true, not_index: false }

  def is_app_index_to_i
    is_index? ? '1' : '0'
  end

  def self.init_sort(shop=nil)
    if shop
      shop.categories.normal.maximum(:sort).to_i + 1
    else
      Category.base_category.normal.maximum(:sort).to_i + 1
    end
  end
end
