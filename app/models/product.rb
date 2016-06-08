class Product < ActiveRecord::Base
  mount_uploader :key, AvatarUploader
  
  belongs_to :category
  belongs_to :sub_category
  belongs_to :detail_category
  belongs_to :unit
  has_many :shop_products
  has_many :images, as: :imageable

  scope :sorted, -> { order('sort DESC') }
  scope :latest, -> { order('created_at DESC') }

  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 1}

  enum status: [ :normal, :deleted ]
  enum is_app_index: { is_index: true, not_index: false }
  enum state: [ :sold_off, :sold_on ]

  def self.init_shop_products(shop)
    Product.normal.sorted.each do |p|
      category = shop.categories.normal.find_by(name: p.category.try(:name))
      sub_category = category.sub_categories.normal.find_by(name: p.sub_category.try(:name)) if category
      detail_category = sub_category.detail_categories.normal.find_by(name: p.detail_category.try(:name)) if sub_category
      shop_product = shop.shop_products.new(product_id: p.id, category_id: category.try(:id), sub_category_id: sub_category.try(:id), detail_category_id: detail_category.try(:id), unit_id: p.unit.try(:id),
        name: p.name, price: p.price, old_price: p.old_price, stock_volume: p.stock_volume, sales_volume: p.sales_volume, desc: p.desc, info: p.info, spec: p.spec, sort: p.sort,
        is_app_index: p.is_app_index, state: p.state)
      begin
        shop_product.key = p.key
      rescue
        Rails.logger.info "======error:#{shop_product.name} key:#{p.key}======"
      ensure
        shop_product.save
      end
      p.images.normal.each do |image|
        shop_product_image = shop_product.images.new
        begin
          shop_product_image.key = image.key
        rescue
          Rails.logger.info "======error:#{shop_product_image.imageable_type} key:#{image.key}======"
        ensure
          shop_product_image.save
        end
      end
    end
  end
end
