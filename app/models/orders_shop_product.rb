class OrdersShopProduct < ActiveRecord::Base
  belongs_to :shop
  belongs_to :order
  belongs_to :shop_product

  enum status: [ :normal, :deleted ]

  scope :by_pro_ids, -> (ids) { where(shop_product_id: ids) }
  scope :one_days, ->(today) { where("date(orders_shop_products.created_at) = ?", today) }
  scope :one_weeks, ->(today) { where("date(orders_shop_products.created_at) >= ? and date(orders_shop_products.created_at) <= ?", (today - 6.day), today) }
  scope :one_months, ->(today) { where("date(orders_shop_products.created_at) >= ? and date(orders_shop_products.created_at) <= ?", (today - 1.month), today) }
  scope :select_time, ->(start_time,end_time) { where("date(orders_shop_products.created_at) >= ? and date(orders_shop_products.created_at) <= ?", start_time, end_time) }

  def self.valid_is_changed(order_id, option_params)
    tmp = false
    option_params.each do |option|
      op = OrdersShopProduct.find_by(order_id: order_id, id: option[:id])
      if op.try(:product_num).to_i != option[:product_num].to_i || op.try(:product_price).to_f != option[:product_price].to_f
        tmp = true
        break
      end
    end
    return tmp
  end

  def self.chart_data(orders_shop_products, date, today, select_time, params)
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      total = orders_shop_products.select_time(start_time, end_time).joins(:shop_product).select('shop_products.name as name, sum(product_num) as num').group('shop_product_id').order("num DESC")
    else
      start_time, end_time, total = OrdersShopProduct.get_date(orders_shop_products, date, today)
    end
    [start_time, end_time, total]
  end

  def self.get_date(orders_shop_products, date, today)
    total = orders_shop_products.send(date, today).joins(:shop_product).select('shop_products.name as name, sum(product_num) as num').group('shop_product_id').order("num DESC")
    if date == "one_days"
      start_time = today
    elsif date == "one_weeks"
      start_time = today - 6.day
    elsif date == "one_months"
      start_time = today - 1.month
    end
    return start_time, today, total
  end

  def self.get_product_stats(total, start_time, end_time)
    h = {}
    product_stats = total.select('date(created_at) as created_date, sum(product_num) as num').group('date(created_at)').order("created_at asc")
    (start_time..end_time).to_a.reverse.each do |day|
      h[day.try(:strftime, "%Y-%m-%d")] = 0
    end
    product_stats.each do |value|
      h[value.created_date.try(:strftime, "%Y-%m-%d")] = value.num
    end
    h.take(31)
  end

  def self.chart_pro_data(orders_shop_products, date, today, select_time, params)
    count = 0
    series = []
    categories = []
    hash = {}
    hash['name'] = '销量'
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      categories, hash['data'], count, total = OrdersShopProduct.get_select_date(orders_shop_products, start_time, end_time, count)
    else
      categories, hash['data'], count, start_time, end_time, total = OrdersShopProduct.get_pro_date(orders_shop_products, date, today, count)
    end
    series << hash
    min_tick = categories.length > 7 ? 6 : nil
    [categories, series, start_time, end_time, count, min_tick, total]
  end

  def self.get_select_date(orders_shop_products, start_time, end_time, count)
    diff_time = (start_time - end_time).to_i
    h = {}
    total = orders_shop_products.select_time(start_time, end_time)
    count = total.sum(:product_num)
    if diff_time <= 31
      product_stats = total.select('date(created_at) as created_date, sum(product_num) as num').group('date(created_at)').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = OrdersShopProduct.get_hash_day(h, product_stats)
    elsif diff_time > 31 &&  diff_time < 365
      product_stats = total.select('year(created_at) as created_year, month(created_at) as created_month, sum(product_num) as num').group('year(created_at),month(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories, data = OrdersShopProduct.get_hash_month(h, product_stats)
    elsif diff_time > 365
      product_stats = total.select('year(created_at) as created_year, sum(product_num) as num').group('year(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s}.uniq.each do |year|
        h[year] = 0
      end
      categories, data = OrdersShopProduct.get_hash_year(h, product_stats)
    end
    return categories, data, count, total
  end

  def self.get_pro_date(orders_shop_products, date, today, count)
    h = {}
    total = orders_shop_products.send(date, today)
    count = total.sum(:product_num)
    product_stats = total.select('date(created_at) as created_date, sum(product_num) as num').group('date(created_at)').order("created_at asc")
    if date == "one_days"
      start_time = today
      h[today.try(:strftime, "%m-%d")] = 0
      categories, data = OrdersShopProduct.get_hash_day(h, product_stats)
    elsif date == "one_weeks"
      start_time = today - 6.day
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = OrdersShopProduct.get_hash_day(h, product_stats)
    elsif date == "one_months"
      start_time = today - 1.month
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories, data = OrdersShopProduct.get_hash_day(h, product_stats)
    end
    return categories, data, count, start_time, today, total
  end

  def self.get_hash_day(h, product_stats)
    product_stats.each do |value|
      h[value.created_date.try(:strftime, "%m-%d")] = value.num
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_month(h, product_stats)
    product_stats.each do |value|
      key = value.created_year.to_s + "-" + value.created_month.to_s
      h[key] = value.num
    end
    categories = h.keys
    data = h.values
    return categories, data
  end

  def self.get_hash_year(h, product_stats)
    product_stats.each do |value|
      key = value.created_year.to_s
      h[key] = value.num
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
      f.title({ text: "产品销量趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "产品销量趋势图"},
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
end
