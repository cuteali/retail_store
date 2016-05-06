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
  enum order_type: [ :cod, :olp ]

  scope :by_page, -> (page_num) { page(page_num) if page_num }
  scope :latest, -> { order('created_at DESC') }
  scope :can_delete, -> { where(state: ['completed', 'canceled']) }
  scope :by_state, -> (state = nil) {
    if state.to_s == '0'
      where(state: STATE)
    elsif state.to_s == '1'
      where(state: ['opening', 'pending'], order_type: 1)
    elsif state.to_s == '2'
      where(state: 'paid')
    elsif state.to_s == '3'
      where(state: 'completed')
    elsif state.to_s == '4'
      where(state: ['canceled', 'refund'])
    end
  }

  STATE = %w(opening pending paid completed refund canceled)
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
    Alipay::Mobile::Service.mobile_securitypay_pay_string({
      out_trade_no: order_no,
      notify_url: Rails.application.routes.url_helpers.alipay_notify_orders_url(host: 'jinhuola.cc'),
      subject: 'subject',
      total_fee: total_price.to_s,
      body: 'text'
    }, {
      sign_type: 'RSA',
      key: 'MIICXgIBAAKBgQDdxoPNsLM10s71ai6CZcNZEn0IY8CrF+XtBeXJit+7yGO67tna
TXDFdIaLHmRQDSWKIP2aAvagJHK9yHbWWFu+yEegR/XwUPEg2sqknLcgyU3rrHi9
eOpT18QAtC0CiDridRr1gm+iJ9I1tSNiwpDMX3tlSpaAEvn5w7D64efHUQIDAQAB
AoGBALSZaVICeB33mtOdcVx89FS/ypQfb5Gkt3eKWvMCJWotKJHc2gl9EL2rQ7lc
uYG7Avv2G67khOQqakoESkoI0EQLXYuc69A21yNqAI7EwBptXZKHH8Vrgy45fnX3
BIB2OBjnRR7rBBTdhA9rb/t13+Dg9WqEXH0z+g+mryF6GsvxAkEA9fTtT8H3ma8+
vdW7LEiLI7weT6VVYYh3RAihPGSZGGQQcAo534CVYnK+dsWGfMNhOGZFsoXeTYOY
U+r62kHV3QJBAObUz+u1ypFMdEQR4rZtaJLnvLvLyp7yQr7aD4M+tULXsVyI5YCQ
lRpApFTBkmSmIk8yWRWqBWJTayf4p0nAYgUCQQCsOfTO67D4kckqXvZw/N9Jh5nm
BYzy/f8dybk1s++sL61+9votcjmotVZ/jrMsvBdgyeS2LJ1MxAAvixRbLsyVAkBd
B9YIjIrohmSxbnftyCiGVIlXMqol50OJQb9QyPwqxV2BCtdcOmktXHIeiqlikSZw
vrzyo0RqPW6JfIiHi9a1AkEApGBnVSAnB2IhqJEYs7T+QdwobL9lpigt9ECZQA7L
lY63/LUucwRq+kFSSjIqGFcTaXISUO8l2zDZ8ahNCqauow=='
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

  # 0 待付款 1 货到付款 2 已支付待收货 3 交易成功 4 退款中 5 交易关闭
  def state_type
    if cod? && state == 'paid'
      '1'
    elsif cod? && state == 'completed'
      '3'
    elsif olp? && %w(opening pending).include?(state)
      '0'
    elsif olp? && state == 'paid'
      '2'
    elsif olp? && state == 'completed'
      '3'
    elsif olp? && state == 'refund'
      '4'
    elsif olp? && state == 'canceled'
      '5'
    end
  end

  def order_type_name
    if cod?
      '货到付款'
    elsif olp?
      '在线支付'
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

  private
    def generate_order_no
      max_order_no = Order.maximum(:order_no) || 1605040
      self.order_no = max_order_no.succ
    end
end
