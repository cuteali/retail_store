module V1
  class ApiFavorite < Grape::API

    version 'v1', using: :path

    resources 'favorites' do
      # http://localhost:3000/api/v1/favorites
      params do
        requires :token, type: String
        requires :shop_id, type: String
        optional :page_num, type: String
      end
      get '', jbuilder: 'v1/favorites/index' do
        authenticate!
        if @token
          @favorites = @current_user.favorites.joins(:shop_product).where( "shop_products.status = 0" ).normal.where(shop_id: params[:shop_id]).latest.by_page(params[:page_num])
        end
      end

      # http://localhost:3000/api/v1/favorites
      params do
        requires :token, type: String
        requires :shop_id, type: String
        requires :product_id, type: String
      end
      post '', jbuilder: 'v1/favorites/create' do
        authenticate!
        if @token
          shop = Shop.normal.find_by(id: params[:shop_id])
          @favorite = @current_user.favorites.create(shop_id: shop.id, shop_product_id: params[:product_id])
        end
      end

      #http://localhost:3000/api/v1/favorites
      params do 
        requires :token, type: String
        requires :id, type: String
      end
      delete '', jbuilder: 'v1/favorites/delete' do
        authenticate!
        if @token
          favorite = @current_user.favorites.normal.find_by(id: params[:id])
          if favorite.present?
            @favorite = favorite.deleted!
          end
        end
      end

      #http://localhost:3000/api/v1/favorites/delete_all
      params do 
        requires :token, type: String
        requires :shop_id, type: String
      end
      get 'delete_all', jbuilder: 'v1/favorites/delete_all' do
        authenticate!
        if @token
          favorites = @current_user.favorites.normal.where(shop_id: params[:shop_id])
          if favorites.present?
            @favorites = favorites.map{|f| f.deleted!}
          end
        end
      end
    end
  end
end
