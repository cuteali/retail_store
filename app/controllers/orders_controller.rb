class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :alipay_notify ]

  def alipay_notify
    notify_params = params.except(*request.path_parameters.keys)
    # 先校验消息的真实性
    if Alipay::Sign.verify?(notify_params) && Alipay::Notify.verify?(notify_params)
      # 获取交易关联的订单
      @order = Order.find_by(order_no: params[:out_trade_no])

      case params[:trade_status]
      when 'WAIT_BUYER_PAY'
        Rails.logger.info "11111111111111"
        # 交易开启
        @order.update_columns(trade_no: params[:trade_no])
        @order.pend
      when 'TRADE_SUCCESS'
        Rails.logger.info "22222222222222"
        # 买家完成支付
        @order.pay
        # 虚拟物品无需发货，所以立即调用发货接口
        @order.send_good
      when 'TRADE_FINISHED'
        Rails.logger.info "33333333333333"
        # 交易完成
        @order.complete
      when 'TRADE_CLOSED'
        Rails.logger.info "44444444444444"
        # 交易被关闭
        @order.cancel
      end

      render :text => 'success' # 成功接收消息后，需要返回纯文本的 ‘success’，否则支付宝会定时重发消息，最多重试7次。 
    else
      render :text => 'error'
    end
  end

  private

    def order_params
      params.require(:order).permit(:quantity)
    end
end
