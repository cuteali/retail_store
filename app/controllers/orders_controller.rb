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
        # 交易开启
        @order.update_columns(trade_no: params[:trade_no])
        @order.pend
      when 'TRADE_SUCCESS'
        # 买家完成支付
        # @order.pay
        @order.update_column :state, 'completed'
        # 虚拟物品无需发货，所以立即调用发货接口
        @order.send_good
      when 'TRADE_FINISHED'
        # 交易完成
        @order.complete
      when 'TRADE_CLOSED'
        # 交易被关闭
        @order.cancel
      end

      render text: 'success'
    else
      render text: 'error'
    end
  end

  private

    def order_params
      params.require(:order).permit(:quantity)
    end
end
