class OrderStatisticsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @orders = Order.normal.is_not_canceled.latest
    select_time = true if params[:start_time].present? && params[:end_time].present?
    @date = params[:created_date].present? ? params[:created_date] : "one_days"
    @today = Date.today
    @categories, @series, @start_time, @end_time, @count, @min_tick, @total = Order.chart_data(@orders, @date, @today, select_time, params)
    @order_stats = Order.get_order_stats(@total, @start_time, @end_time)
    @cod_order_stats = Order.get_order_stats(@total.cod, @start_time, @end_time)
    @olp_order_stats = Order.get_order_stats(@total.olp, @start_time, @end_time)
    @to_shop_order_stats = Order.get_order_stats(@total.to_shop, @start_time, @end_time)
    @chart = Order.chart_base_line(@categories, @series, @min_tick) if @categories.present?
    @categories_amount, @series_amount, start_time, end_time, @amount, @min_tick_amount = Order.chart_data_amount(@orders, @date, @today, select_time, params)
    @chart_amount = Order.chart_base_line_amount(@categories_amount, @series_amount, @min_tick_amount) if @categories_amount.present?
  end

  def show
    @order_shop = Shop.normal.find_by(id: params[:id])
    @orders = @order_shop.orders.normal.is_not_canceled.latest
    select_time = true if params[:start_time].present? && params[:end_time].present?
    @date = params[:created_date].present? ? params[:created_date] : "one_days"
    @today = Date.today
    @categories, @series, @start_time, @end_time, @count, @min_tick, @total = Order.chart_data(@orders, @date, @today, select_time, params)
    @order_stats = Order.get_order_stats(@total, @start_time, @end_time)
    @cod_order_stats = Order.get_order_stats(@total.cod, @start_time, @end_time)
    @olp_order_stats = Order.get_order_stats(@total.olp, @start_time, @end_time)
    @to_shop_order_stats = Order.get_order_stats(@total.to_shop, @start_time, @end_time)
    @chart = Order.chart_base_line(@categories, @series, @min_tick) if @categories.present?
    @categories_amount, @series_amount, start_time, end_time, @amount, @min_tick_amount = Order.chart_data_amount(@orders, @date, @today, select_time, params)
    @chart_amount = Order.chart_base_line_amount(@categories_amount, @series_amount, @min_tick_amount) if @categories_amount.present?
  end
end
