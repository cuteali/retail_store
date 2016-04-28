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

  scope :by_page, -> (page_num) { page(page_num) if page_num }
  scope :latest, -> { order('created_at DESC') }
  scope :by_state, -> (state) { where(state: state) if state }

  STATE = %w(opening pending paid completed canceled refund)
  validates_inclusion_of :state, :in => STATE

  STATE.each do |state|
    define_method "#{state}?" do
      self.state == state
    end
  end

  def pend
    if opening?
      update_column :state, 'pending'
    end
  end

  def pay
    if pending?
      update_column :state, 'paid'
    end
  end

  def complete
    if pendding? or paid?
      update_column :state, 'completed'
    end
  end

  def cancel
    if pendding? or paid?
      update_column :state, 'canceled'
    end
  end

  def send_good
    Alipay::Service.send_goods_confirm_by_platform(
      :trade_no => trade_no,
      :logistics_name => 'jinhuola.cc',
      :transport_type => 'DIRECT' # 无需物流
    )
  end

  def pay_url
    Alipay::Mobile::Service.mobile_securitypay_pay_string(
      out_trade_no: order_no,
      notify_url: alipay_notify_orders_url,
      subject: 'subject',
      total_fee: total_price.to_s,
      body: 'text'
    )
  end

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

  def state_name
    case state
    when 'opening'
      '待付款'
    when 'pending'
      '付款中'
    when 'paid'
      '已付款'
    when 'completed'
      '已完成'
    when 'canceled'
      '已关闭'
    when 'refund'
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
