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
    end

    resources 'orders' do
      # http://localhost:3000/api/v1/orders
      params do 
        requires :token, type: String
        requires :shop_id, type: String
        optional :payment, type: String
        optional :page_num, type: String
      end
      get '', jbuilder: 'v1/orders/index' do
        authenticate!
        if !@erruser
          shop = Shop.normal.find_by(id: params[:shop_id])
          @orders = @current_user.orders.normal.where(shop_id: shop.id).by_payment(params[:payment]).latest.by_page(params[:page_num])
        end
      end

      #http://localhost:3000/api/v1/orders
      params do 
        requires :token, type: String
        requires :shop_id, type: String
        requires :address_id, type: String
        requires :products, type: String
        requires :money, type: String
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
              @stock_num_result = Product.validate_stock_num(product_arr)
              if @stock_num_result == 0
                @order = @current_user.orders.create(shop_id: shop.id, receive_name: address.try(:receive_name), receive_phone: address.try(:receive_phone), area: address.try(:area), detail: address.try(:detail), total_price: total_price)
                @order.create_orders_shop_products(product_arr)
                pro_ids = @order.update_product_stock_num
                AppLog.info("pro_ids:      #{pro_ids}")
                carts = @current_user.carts.where(shop_product_id: pro_ids)
                AppLog.info("carts:   #{@carts.pluck(:id)}")
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
    end
  end
end
