class Product < ActiveRecord::Base
  mount_uploader :key, AvatarUploader
  
  belongs_to :category
  belongs_to :sub_category
  belongs_to :detail_category
  belongs_to :unit
  has_many :shop_products
  has_many :images, as: :imageable

  scope :sorted, -> { order('sort DESC') }

  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 1}

  enum status: [ :normal, :deleted ]

  def self.init_shop_products(shop)
    Product.normal.sorted.each do |p|
      category = shop.categories.normal.find_by(name: p.category.name)
      sub_category = shop.sub_categories.normal.find_by(name: p.sub_category.name)
      detail_category = shop.detail_categories.normal.find_by(name: p.detail_category.name)
      shop_product = shop.shop_products.create(product_id: p.id, category_id: category.id, sub_category_id: sub_category.id, detail_category_id: detail_category.id, unit_id: p.unit.id,
        price: p.price, old_price: p.old_price, stock_volume: p.stock_volume, sales_volume: p.sales_volume, desc: p.desc, info: p.info, spec: p.spec, is_app_index: p.is_app_index)
      shop_product.update_columns(key: p.key.path)
      p.images.normal.each do |image|
        shop_product_image = shop_product.images.create
        shop_product_image.update_columns(key: image.key.path)
      end
    end
  end
end
