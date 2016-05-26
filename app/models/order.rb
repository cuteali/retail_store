class Order < ActiveRecord::Base
  belongs_to :address
  belongs_to :shop
  belongs_to :shopper
  has_many :messages, as: :messageable
  has_many :orders_shop_products, dependent: :destroy
  has_many :shop_products, through: :orders_shop_products
  accepts_nested_attributes_for :orders_shop_products, allow_destroy: true

  validates :order_no, uniqueness: true

  before_create :generate_order_no

  enum status: [ :normal, :deleted ]
  enum order_type: [ :cod, :olp, :to_shop ]

  scope :by_page, -> (page_num) { page(page_num) if page_num }
  scope :latest, -> { order('created_at DESC') }
  scope :can_delete, -> { where(state: ['completed', 'canceled']) }
  scope :not_receiving, -> { where(state: 'paid') }
  scope :receiving, -> { where(state: 'receiving') }
  scope :by_state, -> (state = nil) {
    case state
    when '0' then where(state: STATE)
    when '1' then where('state in (?) and order_type = ? and expiration_at >= ?', ['opening', 'pending'], 1, Time.now)
    when '2' then where(state: ['paid', 'receiving'])
    when '3' then where(state: 'completed')
    when '4' then where('state in (?) or expiration_at < ?', ['canceled', 'refund'], Time.now)
    end
  }
  scope :by_shop_state, -> (state = nil) {
    case state
    when '0' then where("order_type = 0 and state = 'paid' or order_type in (?) and state = 'paid' and expiration_at > ?", [1,2], Time.now)
    when '1' then where(state: 'receiving')
    when '2' then where(state: 'completed')
    when '3' then where(state: 'refund')
    when '4' then where(state: 'canceled')
    end
  }

  STATE = %w(opening pending paid receiving completed refund canceled)
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
    Alipay::Service.send_goods_confirm_by_platform({
      trade_no: trade_no,
      logistics_name: 'jinhuola.cc',
      transport_type: 'DIRECT' # 无需物流
    }, {
      sign_type: 'RSA',
      key: ENV['rsa_private_key']
    })
  end

  def pay_url
    Alipay::Mobile::Service.mobile_securitypay_pay_string({
      out_trade_no: order_no,
      notify_url: Rails.application.routes.url_helpers.alipay_notify_orders_url(host: 'jinhuola.cc'),
      subject: 'subject',
      total_fee: '0.01',
      body: 'text'
    }, {
      sign_type: 'RSA',
      key: ENV['rsa_private_key']
    })
  end

  def get_address
    area.to_s + detail.to_s
  end

  def validate_product_stock_volume
    result = 0
    orders_shop_products.each do |op|
      if op.shop_product.stock_volume < op.product_num
        result = 3
        break
      end
    end
    result
  end

  # 0 待付款 1 货到付款 2 已支付待收货 3 交易成功 4 退款中 5 交易关闭 6 未接单 7 到店自提
  def state_type
    if cod? && state == 'receiving'
      '1'
    elsif to_shop? && state == 'receiving'
      '7'
    elsif olp? && %w(opening pending).include?(state) && !is_expiration
      '0'
    elsif olp? && state == 'receiving'
      '2'
    elsif olp? && state == 'refund'
      '4'
    elsif state == 'canceled' || (%w(olp to_shop).include?(order_type) && is_expiration)
      '5'
    elsif state == 'completed'
      '3'
    elsif state == 'paid'
      '6'
    end
  end

  def order_type_name
    if cod?
      '货到付款'
    elsif olp?
      '在线支付'
    elsif to_shop?
      '到店自提'
    end
  end

  def self.order_type_name(order_type)
    case order_type
    when 'cod'     then '货到付款'
    when 'olp'     then '在线支付'
    when 'to_shop' then '到店自提'
    end
  end

  def create_orders_shop_products(shop, products)
    products.each do |p|
      shop_product = shop.shop_products.find_by(id: p['id'])
      orders_shop_products.where(shop_product_id: shop_product.try(:id), product_num: p['number'], product_price: shop_product.try(:price)).first_or_create
    end
  end

  def update_product_stock_volume
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

  def get_expiration_time
    if olp? && %w(opening pending).include?(state)
      (expiration_at - Time.now).to_i
    else
      0
    end
  end

  def is_expiration
    Time.now > expiration_at
  end

  def restore_products
    orders_shop_products.each do |op|
      op.shop_product.restore_stock_volume(op.product_num)
    end
  end

  def update_total_price
    new_total_price = orders_shop_products.to_a.sum do |op|
      op.product_price * op.product_num
    end
    self.update(total_price: new_total_price)
  end

  def self.state_name(state)
    case state
    when 'opening'   then '已下单'
    when 'pending'   then '支付中'
    when 'paid'      then '未接单'
    when 'receiving' then '已接单'
    when 'completed' then '已完成'
    when 'refund'    then '退款中'
    when 'canceled'  then '已取消'
    end
  end

  def state_name
    case state
    when 'opening'   then '已下单'
    when 'pending'   then '支付中'
    when 'paid'      then '未接单'
    when 'receiving' then '已接单'
    when 'completed' then '已完成'
    when 'refund'    then '退款中'
    when 'canceled'  then '已取消'
    end
  end

  def get_address
    area.to_s + detail.to_s
  end

  private
    def generate_order_no
      max_order_no = Order.maximum(:order_no) || 1605040
      self.order_no = max_order_no.succ
    end
end
