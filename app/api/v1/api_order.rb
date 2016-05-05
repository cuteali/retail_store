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

      def validate_stock_volume(shop, products)
        result = 0
        products.each do |p|
          shop_product = shop.shop_products.find_by(id: p['id'])
          if shop_product.stock_volume < p["number"].to_i
            result = 3
            break
          end
        end
        result
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
        if !@erruser
          @orders = @current_user.orders.normal.by_state(params[:state]).latest.by_page(params[:page_num])
        end
      end

      #http://localhost:3000/api/v1/orders
      params do 
        requires :token, type: String
        requires :shop_id, type: String
        requires :address_id, type: String
        requires :products, type: String
        requires :money, type: String
        requires :order_type, type: String
      end
      post '', jbuilder: 'v1/orders/create' do
        authenticate!
        if !@erruser
          shop = Shop.normal.find_by(id: params[:shop_id])
          AppLog.info("products : #{params[:products]}")
          address = @current_user.addresses.normal.find_by(id: params[:address_id])
          products_json = params[:products].gsub("\\","")
          AppLog.info("products_json : #{products_json}")
          ActiveRecord::Base.transaction do 
            product_arr = JSON.parse(products_json)
            total_price = check_total_price(shop, product_arr)
            AppLog.info("money:#{params[:money]}")
            if total_price == params[:money].gsub(/[^\d\.]/, '').to_f
              @stock_volume_result = validate_stock_volume(shop, product_arr)
              if @stock_volume_result == 0
                state = params[:order_type] == '0' ? 'paid' : 'opening'
                @order = @current_user.orders.create(shop_id: shop.id, address_id: address.try(:id), receive_name: address.try(:receive_name), receive_phone: address.try(:receive_phone), area: address.try(:area), detail: address.try(:detail), total_price: total_price, order_type: params[:order_type].to_i, state: state)
                @order.create_orders_shop_products(shop, product_arr)
                pro_ids = @order.update_product_stock_volume
                AppLog.info("pro_ids:      #{pro_ids}")
                carts = @current_user.carts.where(shop_product_id: pro_ids)
                AppLog.info("carts:   #{carts.pluck(:id)}")
                @carts = carts.destroy_all
              end
            end
          end
        end
      end

      #http://localhost:3000/api/v1/orders/:id
      params do 
        requires :token, type: String
        requires :id, type: String
        requires :shop_id, type: String
      end
      get ':id', jbuilder: 'v1/orders/show' do
        authenticate!
        if !@erruser
          @order = @current_user.orders.normal.find_by(id: params[:id], shop_id: params[:shop_id])
          @shop_products = @order.orders_shop_products.joins(:shop_product).order('shop_products.category_id ASC')
        end
      end

      #http://localhost:3000/api/v1/orders/confirmed
      params do 
        requires :token, type: String
        requires :id, type: String
      end
      get 'confirmed', jbuilder: 'v1/orders/confirmed' do
        authenticate!
        if !@erruser
          order = @current_user.orders.normal.find_by(id: params[:id])
          @order = order.update(state: 'completed')
        end
      end
    end
  end
end
