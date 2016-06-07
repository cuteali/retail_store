class Category < ActiveRecord::Base
  mount_uploader :key, AvatarUploader
  mount_uploader :logo_key, AvatarUploader
  
  belongs_to :shop
  has_many :sub_categories
  has_many :detail_categories
  has_many :products, -> { order "products.sort DESC, products.updated_at DESC" }
  has_many :shop_products, -> { order "shop_products.sort DESC, shop_products.updated_at DESC" }

  scope :sorted, -> { order('sort DESC') }
  scope :latest, -> { order('created_at DESC') }
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

  def self.init_shop_categories(shop)
    Category.base_category.normal.each do |c|
      category = shop.categories.new(name: c.name, name_as: c.name_as, is_app_index: c.is_app_index, sort: c.sort)
      category.key = c.key if c.key
      category.logo_key = c.logo_key if c.logo_key
      category.save
      c.sub_categories.base_category.normal.each do |sc|
        sub_category = shop.sub_categories.create(category_id: category.id, name: sc.name, sort: sc.sort)
        sc.detail_categories.base_category.normal.each do |dc|
          detail_category = shop.detail_categories.new(category_id: category.id, sub_category_id: sub_category.id, name: dc.name, sort: dc.sort)
          detail_category.key = dc.key if dc.key
          detail_category.save
        end
      end
    end
  end
end
