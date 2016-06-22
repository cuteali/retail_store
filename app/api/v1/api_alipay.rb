module V1
  class ApiAlipay < Grape::API

    version 'v1', using: :path

    resources 'alipays' do
      # http://localhost:3000/api/v1/alipays/alipay_string
      params do
        requires :token, type: String
        requires :order_id, type: String
      end
      get 'alipay_string', jbuilder: 'v1/alipays/alipay_string' do
        authenticate!
        if @token
          order = @current_user.orders.normal.find_by(id: params[:order_id])
          if order
            order.alipay!
            @pay_url = order.pay_url
            @is_expiration = order.is_expiration
          end
        end
      end
    end
  end
end
