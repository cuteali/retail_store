module V1
  class ApiCart < Grape::API

    version 'v1', using: :path

    before do
      @shop = Shop.normal.find_by(id: params[:shop_id])
    end

    resources 'carts' do

      # http://localhost:3000/api/v1/carts/:token
      params do 
        requires :token, type: String
        requires :shop_id, type: String
      end
      get ':token', jbuilder: 'v1/carts/index' do
        authenticate!
        if !@erruser
          @carts = @current_user.carts.joins(:shop_product).where(shop_id: @shop.id).normal.group_by{ |cart| cart.shop_product.category.name }
        end
      end

      #http://localhost:3000/api/v1/carts
      params do 
        requires :token, type: String
        requires :shop_id, type: String
        requires :product_id, type: String
        requires :product_num, type: String
      end
      post '', jbuilder: 'v1/carts/create' do
        authenticate!
        if !@erruser
          product = @shop.shop_products.find_by(id: params[:product_id])
          cart = @current_user.carts.find_by(shop_id: @shop.id, shop_product_id: product.id)
          if cart
            cart.product_num += params[:product_num].to_i
            @cart = cart.save
          else
            @cart = @current_user.carts.create(shop_id: @shop.id, shop_product_id: product.id, product_num: params[:product_num])
          end
        end
      end

      #http://localhost:3000/api/v1/carts/edit_product_num
      params do 
        requires :token, type: String
        requires :shop_id, type: String
        requires :cart_id, type: String
        requires :product_num, type: String
      end
      post 'edit_product_num', jbuilder: 'v1/carts/edit_product_num' do
        authenticate!
        if !@erruser
          cart = @current_user.carts.find_by(shop_id: @shop.id, id: params[:cart_id])
          @cart = cart.update(product_num: params[:product_num])
        end
      end

      #http://localhost:3000/api/v1/carts
      params do 
        requires :token, type: String
        requires :shop_id, type: String
        requires :cart_ids, type: String
      end
      delete '', jbuilder: 'v1/carts/delete' do
        AppLog.info("cart_ids: #{params[:cart_ids]}")
        cart_ids_json = JSON.parse(params[:cart_ids].gsub("\\",""))
        AppLog.info("cart_ids_json:  #{cart_ids_json}")
        authenticate!
        if !@erruser
          ActiveRecord::Base.transaction do
            carts = @current_user.carts.where(shop_id: @shop.id, id: cart_ids_json)
            AppLog.info("ids:   #{carts.pluck(:id)}")
            @carts = carts.destroy_all
          end
        end
      end
    end
  end
end
