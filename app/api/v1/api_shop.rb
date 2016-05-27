module V1
  class ApiShop < Grape::API

    version 'v1', using: :path

    helpers do
      def get_state_and_msg(state, order)
        if state == '0'
          order.update(delivery_at: Time.now)
          ['receiving', '接单成功']
        elsif state == '1'
          order.update(complete_at: Time.now)
          ['completed', '订单已完成']
        elsif state == '2' && order.olp?
          ['refund', '订单退款中']
        elsif state == '3' || (state == '2' && order.cod?)
          ['canceled', '订单已成功关闭']
        end
      end
    end

    resources 'shops' do
      # http://localhost:3000/api/v1/shops
      # state: 0待接单 1配送中 2已完成 3待退款 4已取消
      params do 
        requires :token, type: String
        requires :state, type: String
        optional :page_num, type: String
      end
      get '', jbuilder: 'v1/shops/index' do
        authenticate_shop!
        if @shop_token
          orders = @current_shop.shop.orders.normal
          Order.update_expiration_at_state(orders)
          @orders = orders.by_shop_state(params[:state]).latest.by_page(params[:page_num])
        end
      end

      #http://localhost:3000/api/v1/shops/show/:id
      params do 
        requires :token, type: String
        requires :id, type: String
      end
      get 'show/:id', jbuilder: 'v1/shops/show' do
        authenticate_shop!
        if @shop_token
          @order = @current_shop.shop.orders.normal.find_by(id: params[:id])
          if @order
            @order.update_expiration_at_state
            @shop_products = @order.orders_shop_products.joins(:shop_product).order('shop_products.category_id ASC')
          end
        end
      end

      #http://localhost:3000/api/v1/shops/update_state
      #state 0接单 1确认收款/配送 2同意取消 3退款完成
      params do 
        requires :token, type: String
        requires :id, type: String
        requires :state, type: String
      end
      get 'update_state', jbuilder: 'v1/shops/update_state' do
        authenticate_shop!
        if @shop_token
          order = @current_shop.shop.orders.normal.find_by(id: params[:id])
          state, @msg = get_state_and_msg(params[:state], order)
          @order = order.update(state: state)
          Message.push_message_to_shopper(order) if params[:state] == '0'
        end
      end
    end
  end
end
