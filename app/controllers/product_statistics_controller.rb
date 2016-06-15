class ProductStatisticsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @product_shop = Shop.normal.find_by(id: params[:id])
    @q = @product_shop.shop_products.normal.ransack(params[:q])
    shop_product_ids = @q.result.pluck(:id)
    if params[:q] && params[:q][:category_id_eq]
      @orders_shop_products = @product_shop.orders_shop_products.normal.by_pro_ids(shop_product_ids)
    else
      @orders_shop_products = @product_shop.orders_shop_products.normal
    end
    select_time = true if params[:start_time].present? && params[:end_time].present?
    @date = params[:created_date].present? ? params[:created_date] : "one_days"
    @today = Date.today
    @start_time, @end_time, @total = OrdersShopProduct.chart_data(@orders_shop_products, @date, @today, select_time, params)
    @orders_shop_products_stats = @total.page(params[:page])
  end
end
