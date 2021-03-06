module V1
  class ApiWxpay < Grape::API

    version 'v1', using: :path

    resources 'wxpays' do
      # http://localhost:3000/api/v1/wxpays/unifiedorder
      params do
        requires :token, type: String
        requires :order_id, type: String
      end
      get 'unifiedorder', jbuilder: 'v1/wxpays/unifiedorder' do
        authenticate!
        if @token
          @order = @current_user.orders.normal.find_by(id: params[:order_id])
          if @order
            @order.wxpay!
            remote_ip = request.env['REMOTE_HOST'] || request.env['HTTP_X_REAL_IP'] || '139.196.166.7'
            @pay_sign = @order.pay_unifiedorder(remote_ip)
            @order.pend if @pay_sign
            @is_expiration = @order.is_expiration
          end
        end
      end
    end
  end
end
