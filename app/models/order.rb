class Order < ActiveRecord::Base
  belongs_to :address
  belongs_to :shop
  belongs_to :shopper
  has_many :orders_shop_products, dependent: :destroy
  has_many :shop_products, through: :orders_shop_products
  accepts_nested_attributes_for :orders_shop_products, allow_destroy: true

  validates :order_no, uniqueness: true

  before_create :generate_order_no

  enum status: [ :normal, :deleted ]
  enum payment: [ :paying, :receipt, :finished, :refund ]

  scope :by_page, -> (page_num) { page(page_num) if page_num }
  scope :latest, -> { order('created_at DESC') }
  scope :by_payment, -> (payment) { send(payment) if payment }

  def get_address
    area.to_s + detail.to_s
  end

  def validate_product_stock_num
    result = 0
    orders_shop_products.each do |op|
      if op.shop_product.stock_num < op.product_num
        result = 3
        break
      end
    end
    result
  end

  def payment_name
    case payment
    when 0
      '待付款'
    when 1
      '待收货'
    when 2
      '已完成'
    when 3
      '已退款'
    end
  end

  def create_orders_shop_products(shop, products)
    products.each do |p|
      shop_product = shop.shop_products.find_by(id: p['id'])
      self.orders_shop_products.where(shop_product_id: shop_product.try(:id), product_num: p['number'], product_price: shop_product.try(:price)).first_or_create
    end
  end

  def update_product_stock_num
    pro_ids = []
    orders_shop_products.each do |op|
      if op.shop_product.stock_volume >= op.product_num
        pro_ids << op.shop_product_id
        op.shop_product.stock_volume -= op.product_num
        op.shop_product.sales_volume += op.product_num
        op.shop_product.save
      else
        break
      end
    end
    pro_ids
  end

  private
    def generate_order_no
      max_order_no = Order.maximum(:order_no) || 1603030
      self.order_no = max_order_no.succ
    end
end
