class ShopProduct < ActiveRecord::Base
  mount_uploader :key, AvatarUploader
  
  belongs_to :shop
  belongs_to :product
  belongs_to :category
  belongs_to :sub_category
  belongs_to :detail_category
  belongs_to :unit
  has_many :images, as: :imageable
  has_many :orders_shop_products
  has_many :carts
  has_one :advert
  has_many :messages, as: :messageable

  scope :shelves, -> { where(state: 1) }
  scope :sorted, -> { order('sort DESC') }
  scope :by_page, -> (page_num) { page(page_num) if page_num }
  scope :name_like, -> (name) { where('name like ?', "%#{name}%") if name.present? }

  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 1}

  enum status: [ :normal, :deleted ]
  enum is_app_index: { is_index: true, not_index: false }
  enum state: [ :sold_off, :sold_on ]

  def is_app_index_name
    is_index? ? '是' : '否'
  end

  def state_name
    sold_off? ? '下架' : '上架'
  end

  def is_app_index_to_i
    is_index? ? '1' : '0'
  end

  def self.validate_stock_volume(shop, products)
    result = 0
    products.each do |p|
      shop_product = shop.shop_products.find_by(id: p['id'])
      if shop_product.stock_volume < p['number'].to_i
        result = 3
        break
      end
    end
    result
  end

  def restore_stock_volume(number)
    self.stock_volume += number.to_i
    self.sales_volume -= number.to_i
    self.save
  end

  def add_sales_volume(number)
    self.stock_volume -= number.to_i
    self.sales_volume += number.to_i
    self.save
  end

  def self.init_sort(shop)
    shop.shop_products.normal.maximum(:sort).to_i + 1
  end
end
