class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :alipay_notify, :weixin_notify ]
  before_action :set_order, only: [:edit, :update, :destroy, :show, :add_order_product]
  before_filter :authenticate_user!, except: [ :alipay_notify, :weixin_notify ]
  
  def index
    orders = @shop.orders.normal
    Order.update_expiration_at_state(orders)
    @q = orders.ransack(params[:q])
    @orders = @q.result.latest.page(params[:page])
  end

  def edit
    render :form
  end

  def update
    is_changed = OrdersShopProduct.valid_is_changed(@order.id, order_params[:orders_shop_products_attributes])
    @order.restore_products if is_changed
    if @order.update(order_params)
      if is_changed
        @order.update_total_price
        @order.update_product_stock_volume
      end
      status = @order.canceled? ? 'deleted' : 'normal'
      @order.change_orders_shop_products_status(status)
      flash[:success] = '修改成功！'
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to orders_path
    else
      flash[:danger] = '修改失败！'
      redirect_to :back
    end
  end

  def destroy
    @order.deleted!
    @order.change_orders_shop_products_status('deleted')
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  def show
    @shop_products = @order.shop_products.normal.group_by(&:category_id)
  end

  def delete_order_product
    @order = @shop.orders.normal.find_by(id: params[:order_id])
    orders_shop_product = @order.orders_shop_products.find_by(id: params[:id])
    orders_shop_product.deleted!
    flash[:success] = '删除成功！'
    redirect_to :back
  end

  def add_order_product
    shop_product = @shop.shop_products.normal.find_by(id: params[:shop_product_id])
    return redirect_to :back if shop_product.blank?
    orders_shop_product = @order.orders_shop_products.new(shop_product_id: shop_product.id, product_num: params[:product_num], product_price: params[:product_price])
    if params[:product_num].to_i > shop_product.stock_volume
      flash[:danger] = "保存失败，产品库存不足！"
    elsif orders_shop_product.save
      @order.update_total_price
      orders_shop_product.shop_product.add_sales_volume(orders_shop_product.product_num)
      flash[:success] = "保存成功！"
    else
      flash[:danger] = "保存失败！"
    end
    redirect_to :back
  end

  def select_product
    shop_product = @shop.shop_products.normal.find_by(id: params[:shop_product_id])
    html = get_select_product_html(shop_product)
    render json: {html: html, product_id: shop_product.id}
  end

  def change_is_receiving
    @shop.update(is_receiving: params[:is_receiving])
    render js: 'void(0);'
  end

  def alipay_notify
    notify_params = params.except(*request.path_parameters.keys)
    # 先校验消息的真实性
    if Alipay::Sign.verify?(notify_params) && Alipay::Notify.verify?(notify_params)
      # 获取交易关联的订单
      @order = Order.find_by(order_no: params[:out_trade_no])
      case params[:trade_status]
      when 'WAIT_BUYER_PAY'
        # 交易开启
        @order.update_columns(trade_no: params[:trade_no])
        @order.pend
      when 'TRADE_SUCCESS'
        # 买家完成支付
        @order.pay
        # @order.update_column :state, 'completed'
        # 虚拟物品无需发货，所以立即调用发货接口
        @order.send_good
      when 'TRADE_FINISHED'
        # 交易完成
        # @order.complete
        @order.pay
      when 'TRADE_CLOSED'
        # 交易被关闭
        @order.cancel
      end

      render text: 'success'
    else
      render text: 'error'
    end
  end

  def weixin_notify
    result = Hash.from_xml(request.body.read)["xml"]
    Rails.logger.info "weixin pay notify info -> #{result}"
    return_code = result[:return_code]
    if return_code == "SUCCESS"
      order = Order.find_by(order_no: params[:out_trade_no])
      order.pend
      result_code = result[:result_code]
      if result_code == "SUCCESS"
        if order.paid?
          return render text: Weixinpay.notify_result(return_code: 'SUCCESS', return_msg: 'OK') 
        else
          order.pay
          return render text: Weixinpay.notify_result(return_code: 'SUCCESS', return_msg: 'OK')   
        end  
      else
        Rails.logger.info "weixin v2 pay notify faild -> #{result}" 
        return render text: Weixinpay.notify_result(return_code: 'FAIL', return_msg: 'FAIL')   
      end  
    else
      Rails.logger.info "weixin v2 pay notify faild -> #{result}" 
      return render text: Weixinpay.notify_result(return_code: 'FAIL', return_msg: 'FAIL')   
    end  
  rescue => e
     Rails.logger.info "weixin v2 pay notify exception -> #{e.backtrace}"
     return render text: Weixinpay.notify_result(return_code: 'FAIL', return_msg: 'FAIL')
  end

  private 
    def set_order
      @order = @shop.orders.normal.find_by(id: params[:id])
    end

    def order_params
      params.require(:order).permit(:receive_name, :receive_phone, :area, :detail, :order_type, :state, :delivery_at, :complete_at, :expiration_at, :remarks, :freight, orders_shop_products_attributes: [:id, :product_num, :product_price])
    end
end
