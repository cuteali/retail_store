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
  enum shopper_del: [ :not_del, :is_del ]
  enum order_type: [ :cod, :olp, :to_shop ]
  enum pay_type: [ :alipay, :wxpay ]

  scope :by_page, -> (page_num) { page(page_num) if page_num }
  scope :latest, -> { order('created_at DESC') }
  scope :can_delete, -> { where(state: ['completed', 'canceled']) }
  scope :not_receiving, -> { where(state: 'paid') }
  scope :receiving, -> { where(state: 'receiving') }
  scope :completed, -> { where(state: 'completed') }
  scope :by_expiration, -> { where("order_type in (?) and expiration_at < ?", [1, 2], Time.now) }
  scope :by_state, -> (state = nil) {
    case state
    when '0' then where(state: STATE)
    when '1' then where('state in (?) and order_type in (?) and expiration_at >= ?', ['opening', 'pending'], [1, 2], Time.now)
    when '2' then where(state: ['paid', 'receiving'])
    when '3' then where(state: 'completed')
    when '4' then where('state in (?) or expiration_at < ?', ['canceled', 'refund'], Time.now)
    end
  }
  scope :by_shop_state, -> (state = nil) {
    case state
    when '0' then where("order_type = 0 and state = 'paid' or order_type in (?) and state = 'paid' and expiration_at >= ?", [1, 2], Time.now)
    when '1' then where(state: 'receiving')
    when '2' then where(state: 'completed')
    when '3' then where(state: 'refund')
    when '4' then where(state: 'canceled')
    when '5' then where(state: STATE)
    end
  }
  scope :one_days, ->(today) { where("date(created_at) = ?", today) }
  scope :one_weeks, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 6.day), today) }
  scope :one_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 1.month), today) }
  scope :select_time, ->(start_time,end_time) { where("date(created_at) >= ? and date(created_at) <= ?", start_time, end_time) }

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
    if pending? || canceled?
      new_state = shop.turn_on? ? 'receiving' : 'paid'
      update_column :state, new_state
      Message.push_message_to_user(self)
      send_to_user
    end
  end

  def complete
    if pendding? || paid?
      update_column :state, 'completed'
    end
  end

  def cancel
    if pendding? || paid?
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
      subject: "醉食汇订单：#{order_no}",
      total_fee: (total_price + freight).to_s,
      body: 'text'
    }, {
      sign_type: 'RSA',
      key: ENV['rsa_private_key']
    })
  end

  def pay_unifiedorder(remote_ip)
    self.update_columns(nonce_str: Weixinpay.generate_noce_str)
    request_options = {
      appid: ENV['weixin_appid'], 
      mch_id: ENV['weixin_mch_id'], 
      nonce_str: nonce_str, 
      body: "醉食汇订单：#{order_no}", 
      out_trade_no: order_no, 
      total_fee: ((total_price + freight).to_f * 100).to_i, 
      spbill_create_ip: remote_ip, 
      notify_url: Rails.application.routes.url_helpers.orders_weixin_notify_url(host: 'jinhuola.cc'), 
      trade_type: "APP", 
      time_start: created_at.strftime('%Y%m%d%H%M%S'),
      time_expire: expiration_at.strftime('%Y%m%d%H%M%S')
    }
    Rails.logger.info "weixin pay request_options : #{request_options}"
    sign_params = Weixinpay.set_sign_params(request_options)
    Rails.logger.info "sign_params : #{sign_params}"
    sign = Weixinpay.get_sign(sign_params, ENV['weixin_key'])
    Rails.logger.info "weixin pay first sign : #{sign}"
    xml = Weixinpay.create_xml(request_options, sign)
    weixin_result = Weixinpay.request_unifiedorder(xml)
    response_unifiedorder(weixin_result)
  end

  def response_unifiedorder(weixin_result)
    result = HashWithIndifferentAccess.new(Hash.from_xml weixin_result)[:xml]
    Rails.logger.info "weixin_result : #{result}"
    return_code =  result[:return_code]
    if return_code == "SUCCESS"
      result_code = result[:result_code]
      if result_code == "SUCCESS"
        self.update_columns(prepay_id: result[:prepay_id])
        set_pay_sign_params
      else
        Rails.logger.info "weixin pay error order order_no : #{order_no}, error: #{result}"
      end  
    elsif return_code == "FAIL"
      Rails.logger.info "weixin pay error order order_no : #{order_no}, error: #{result}"
    else 
      Rails.logger.info "weixin pay error order order_no : #{order_no}, error: #{result}"
    end  
  end  

  def set_pay_sign_params
    # pay_sign_nonce_str = Weixinpay.generate_noce_str
    pay_sign_time_stamp = Weixinpay.get_time_stamp
    Rails.logger.info "pay_sign_time_stamp : #{pay_sign_time_stamp}"
    pay_sign_params = [
      "appid=#{ENV['weixin_appid']}", 
      "partnerid=#{ENV['weixin_mch_id']}",
      "package=Sign=WXPay", 
      "timestamp=#{pay_sign_time_stamp}",
      "prepayid=#{prepay_id}",  
      "noncestr=#{nonce_str}"
    ]
    Rails.logger.info "pay_sign_params : #{pay_sign_params}"
    pay_sign = Weixinpay.get_sign(pay_sign_params, ENV['weixin_key'])
    Rails.logger.info "weixin pay sign : #{pay_sign}"
    pay_sign
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
    elsif %w(olp to_shop).include?(order_type) && %w(opening pending).include?(state) && !is_expiration
      '0'
    elsif olp? && state == 'receiving'
      '2'
    elsif olp? && state == 'refund'
      '4'
    elsif state == 'canceled'
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
      orders_shop_products.where(shop_id: shop_id, shop_product_id: shop_product.try(:id), product_num: p['number'], product_price: shop_product.try(:price)).first_or_create
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
    if %w(olp to_shop).include?(order_type) && %w(opening pending).include?(state)
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
    when 'opening'   then '未支付'
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
    when 'opening'   then '未支付'
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

  def self.update_expiration_at_state(orders)
    orders.by_expiration.each do |order|
      if ['opening', 'pending'].include?(order.state)
        order.update(state: 'canceled')
      end
    end
  end

  def update_expiration_at_state
    if ['opening', 'pending'].include?(state)
      self.update(state: 'canceled') if is_expiration
    end
  end

  def self.get_order_stats(total, start_time, end_time)
    h = {}
    order_stats = total.select('date(created_at) as created_date, count(*) as count, sum(total_price) as money').group('date(created_at)').order("created_at asc")
    (start_time..end_time).to_a.reverse.each do |day|
      h[day.try(:strftime, "%Y-%m-%d")] = 0
    end
    order_stats.each do |value|
      h[value.created_date.try(:strftime, "%Y-%m-%d")] = [value.count, value.money]
    end
    h.take(31)
  end

  def self.chart_data(orders, date, today, select_time, params)
    count = 0
    series = []
    categories = []
    hash = {}
    hash['name'] = '订单'
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      categories, hash['data'], count, total = Order.get_select_date(orders, start_time, end_time, count)
    else
      categories, hash['data'], count, start_time, end_time, total = Order.get_date(orders, date, today, count)
    end
    series << hash
    min_tick = categories.length > 7 ? 6 : nil
    [categories, series, start_time, end_time, count, min_tick, total]
  end

  def self.get_select_date(orders, start_time, end_time, count)
    diff_time = (start_time - end_time).to_i
    h = {}
    total = orders.select_time(start_time, end_time)
    count = total.length
    if diff_time <= 31
      order_stats = total.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day(h, order_stats)
    elsif diff_time > 31 &&  diff_time < 365
      order_stats = total.select('year(created_at) as created_year, month(created_at) as created_month, count(*) as count').group('year(created_at),month(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories, data = Order.get_hash_month(h, order_stats)
    elsif diff_time > 365
      order_stats = total.select('year(created_at) as created_year, count(*) as count').group('year(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s}.uniq.each do |year|
        h[year] = 0
      end
      categories, data = Order.get_hash_year(h, order_stats)
    end
    return categories, data, count, total
  end

  def self.get_date(orders, date, today, count)
    h = {}
    total = orders.send(date, today)
    count = total.length
    order_stats = total.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
    if date == "one_days"
      start_time = today
      h[today.try(:strftime, "%m-%d")] = 0
      categories, data = Order.get_hash_day(h, order_stats)
    elsif date == "one_weeks"
      start_time = today - 6.day
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day(h, order_stats)
    elsif date == "one_months"
      start_time = today - 1.month
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day(h, order_stats)
    end
    return categories, data, count, start_time, today, total
  end

  def self.get_hash_day(h, order_stats)
    order_stats.each do |value|
      h[value.created_date.try(:strftime, "%m-%d")] = value.count
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_month(h, order_stats)
    order_stats.each do |value|
      key = value.created_year.to_s + "-" + value.created_month.to_s
      h[key] = value.count
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_year(h, order_stats)
    order_stats.each do |value|
      key = value.created_year.to_s
      h[key] = value.count
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.chart_base_line(categories, series, min_tick)
    @chart = LazyHighCharts::HighChart.new('chart_basic_line1') do |f|
      f.chart({ type: 'line',
          marginRight: 10,
          # marginBottom: 25,
          height: 305
          })
      f.title({ text: "订单量趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "订单量趋势图"},
          plotLines: [{
              value: 0,
              width: 1,
              color: '#808080'
            }]
        })
      f.tooltip({
          valueSuffix: "个"
        })
      f.legend({
          layout: 'horizontal',
          width: 500,
          borderWidth: 0
        })
      series.each do |serie|
        f.series({
          name: serie['name'],
          data: serie['data']
        })
      end
    end
  end

  def self.chart_data_amount(orders, date, today, select_time, params)
    amount = 0
    series = []
    categories = []
    hash = {}
    hash['name'] = '订单'
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      categories, hash['data'], amount = Order.get_select_date_amount(orders, start_time, end_time, amount)
    else
      categories, hash['data'], amount, start_time, end_time = Order.get_date_amount(orders, date, today, amount)
    end
    series << hash
    min_tick = categories.length > 7 ? 6 : nil
    [categories, series, start_time, end_time, amount, min_tick]
  end

  def self.get_select_date_amount(orders, start_time, end_time, amount)
    diff_time = (start_time - end_time).to_i
    h = {}
    total = orders.select_time(start_time, end_time)
    amount = total.sum(:total_price)
    if diff_time <= 31
      order_stats = total.select('date(created_at) as created_date, sum(total_price) as amount').group('date(created_at)').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day_amount(h, order_stats)
    elsif diff_time > 31 &&  diff_time < 365
      order_stats = total.select('year(created_at) as created_year, month(created_at) as created_month, sum(total_price) as amount').group('year(created_at),month(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories, data = Order.get_hash_month_amount(h, order_stats)
    elsif diff_time > 365
      order_stats = total.select('year(created_at) as created_year, sum(total_price) as amount').group('year(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s}.uniq.each do |year|
        h[year] = 0
      end
      categories, data = Order.get_hash_year_amount(h, order_stats)
    end
    return categories, data, amount
  end

  def self.get_date_amount(orders, date, today, amount)
    h = {}
    total = orders.send(date, today)
    amount = total.sum(:total_price)
    order_stats = total.select('date(created_at) as created_date, sum(total_price) as amount').group('date(created_at)').order("created_at asc")
    if date == "one_days"
      start_time = today
      h[today.try(:strftime, "%m-%d")] = 0
      categories, data = Order.get_hash_day_amount(h, order_stats)
    elsif date == "one_weeks"
      start_time = today - 6.day
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day_amount(h, order_stats)
    elsif date == "one_months"
      start_time = today - 1.month
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = Order.get_hash_day_amount(h, order_stats)
    end
    return categories, data, amount, start_time, today
  end

  def self.get_hash_day_amount(h, order_stats)
    order_stats.each do |value|
      h[value.created_date.try(:strftime, "%m-%d")] = value.amount.to_f
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_month_amount(h, order_stats)
    order_stats.each do |value|
      key = value.created_year.to_s + "-" + value.created_month.to_s
      h[key] = value.amount.to_f
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_year_amount(h, order_stats)
    order_stats.each do |value|
      key = value.created_year.to_s
      h[key] = value.amount.to_f
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.chart_base_line_amount(categories, series, min_tick)
    @chart = LazyHighCharts::HighChart.new('chart_basic_line2') do |f|
      f.chart({ type: 'line',
          marginRight: 10,
          # marginBottom: 25,
          height: 305
          })
      f.title({ text: "交易额趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "交易额趋势图"},
          plotLines: [{
              value: 0,
              width: 1,
              color: '#808080'
            }]
        })
      f.tooltip({
          valueSuffix: "元"
        })
      f.legend({
          layout: 'horizontal',
          width: 500,
          borderWidth: 0
        })
      series.each do |serie|
        f.series({
          name: serie['name'],
          data: serie['data']
        })
      end
    end
  end

  def send_to_user
    phones = shop.users.normal.user.pluck(:phone)
    if phones.present?
      text = "【醉食汇】您好，您有新的订单，请查收～"
      @errcode = Sms.send_sms(phones.uniq, text)
      AppLog.info("info:#{@errcode}")
    end
  end

  def change_orders_shop_products_status(status)
    orders_shop_products.each do |op|
      op.update(status: status)
    end
  end

  private
    def generate_order_no
      max_order_no = Order.maximum(:order_no) || 1606220000
      self.order_no = max_order_no.succ
    end
end
