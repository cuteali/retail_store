module V1
  class ApiOrder < Grape::API

    version 'v1', using: :path

    helpers do
      def check_total_price(shop, products)
        total_price = 0
        products.each do |p|
          shop_product = shop.shop_products.find_by(id: p['id'])
          total_price += shop_product.price * p['number'].to_i
        end
        total_price
      end

      def valid_product_num_and_state(shop, products)
        not_enough_products = []
        sold_off_products = []
        products.each do |p|
          shop_product = shop.shop_products.find_by(id: p['id'])
          if shop_product.sold_off?
            sold_off_products << shop_product.name
          end
          if shop_product.stock_volume < p["number"].to_i
            not_enough_products << shop_product.name
          end
        end
        [not_enough_products, sold_off_products]
      end

      def get_order_type_and_state(order_type)
        case order_type
        when '0' then ['paid', 'cod']
        when '1' then ['opening', 'olp']
        when '2' then ['opening', 'to_shop']
        end
      end

      def set_expiration_time(order)
        if %w(olp to_shop).include?(order.order_type)
          order.update_columns(expiration_at: order.created_at + 30.minutes)
        end
      end

      def valid_send_price(shop, total_price, order_type)
        if (total_price < shop.send_price) && order_type != '2'
          shop.freight
        else
          0
        end
      end
    end

    resources 'orders' do
      # http://localhost:3000/api/v1/orders
      # state: 0全部 1待付款 2待收货 3已完成 4已取消
      params do 
        requires :token, type: String
        requires :state, type: String
        optional :page_num, type: String
      end
      get '', jbuilder: 'v1/orders/index' do
        authenticate!
        if @token
          orders = @current_user.orders.normal.not_del
          Order.update_expiration_at_state(orders)
          @orders = orders.by_state(params[:state]).latest.by_page(params[:page_num])
        end
      end

      #http://localhost:3000/api/v1/orders
      params do 
        requires :token, type: String
        requires :shop_id, type: String
        requires :receive_name, type: String
        requires :receive_phone, type: String
        requires :area, type: String
        requires :detail, type: String
        requires :products, type: String
        requires :money, type: String
        requires :order_type, type: String
        optional :remarks, type: String
      end
      post '', jbuilder: 'v1/orders/create' do
        authenticate!
        if @token
          shop = Shop.normal.find_by(id: params[:shop_id])
          AppLog.info("products : #{params[:products]}")
          products_json = params[:products].gsub("\\","")
          AppLog.info("products_json : #{products_json}")
          ActiveRecord::Base.transaction do 
            product_arr = JSON.parse(products_json)
            total_price = check_total_price(shop, product_arr)
            AppLog.info("money:#{params[:money]}")
            if total_price == params[:money].gsub(/[^\d\.]/, '').to_f
              @not_enough_products, @sold_off_products = valid_product_num_and_state(shop, product_arr)
              if @not_enough_products.blank? && @sold_off_products.blank?
                freight = valid_send_price(shop, total_price, params[:order_type])
                state, order_type = get_order_type_and_state(params[:order_type])
                @order = @current_user.orders.create(shop_id: shop.id, receive_name: params[:receive_name], receive_phone: params[:receive_phone], area: params[:area], 
                  detail: params[:detail], total_price: total_price, freight: freight, order_type: order_type, state: state, remarks: params[:remarks])
                set_expiration_time(@order)
                @order.create_orders_shop_products(shop, product_arr)
                pro_ids = @order.update_product_stock_volume
                AppLog.info("pro_ids:      #{pro_ids}")
                carts = @current_user.carts.where(shop_product_id: pro_ids)
                AppLog.info("carts:   #{carts.pluck(:id)}")
                @carts = carts.destroy_all
                if @order.cod?
                  Message.push_message_to_user(@order)
                  @order.send_to_user
                end
              end
            end
          end
        end
      end

      #http://localhost:3000/api/v1/orders/show/:id
      params do 
        requires :token, type: String
        requires :id, type: String
      end
      get 'show/:id', jbuilder: 'v1/orders/show' do
        authenticate!
        if @token
          @order = @current_user.orders.normal.find_by(id: params[:id])
          if @order
            @order.update_expiration_at_state
            @shop_products = @order.orders_shop_products.joins(:shop_product).order('shop_products.category_id ASC')
          end
        end
      end

      #http://localhost:3000/api/v1/orders/confirmed
      params do 
        requires :token, type: String
        requires :id, type: String
      end
      get 'confirmed', jbuilder: 'v1/orders/confirmed' do
        authenticate!
        if @token
          order = @current_user.orders.normal.find_by(id: params[:id])
          @order = order.update(state: 'completed', complete_at: Time.now)
        end
      end

      #http://localhost:3000/api/v1/orders
      params do 
        requires :token, type: String
        requires :id, type: String
      end
      delete '', jbuilder: 'v1/orders/delete' do
        authenticate!
        if @token
          order = @current_user.orders.normal.can_delete.find_by(id: params[:id])
          if order.present?
            @order = order.is_del!
          end
        end
      end
    end
  end
end
