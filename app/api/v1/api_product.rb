module V1
  class ApiProduct < Grape::API

    version 'v1', using: :path

    resources 'products' do

      # http://localhost:3000/api/v1/products/show/:id
      params do
        requires :shop_id, type: String
        requires :id, type: String
        optional :token, type: String
      end
      get 'show/:id', jbuilder: 'v1/products/show' do
        authenticate! if params[:token]
        shop = Shop.normal.find_by(id: params[:shop_id])
        @shop_product = shop.shop_products.normal.find_by(id: params[:id])
        @favorite = shop.favorites.normal.find_by(shopper_id: @current_user.try(:id), shop_product_id: @shop_product.try(:id))
      end

      #http://localhost:3000/api/v1/products/search
      params do
        requires :name_like, type: String
        requires :shop_id, type: String
        optional :page_num, type: String
      end
      get 'search', jbuilder: 'v1/products/search' do
        shop = Shop.normal.find_by(id: params[:shop_id])
        shop ||= Shop.normal.first
        if shop
          @shop_products = shop.shop_products.normal.name_like(params[:name_like]).sorted.by_page(params[:page_num])
        end
        @top_shop_products = shop.shop_products.normal.sorted.limit(2) if @shop_products.blank?
      end

      # http://localhost:3000/api/v1/products/sub_category/:id
      params do
        requires :id, type: String
        requires :shop_id, type: String
        optional :page_num, type: String
      end
      get 'sub_category/:id', jbuilder: 'v1/products/sub_category' do
        shop = Shop.normal.find_by(id: params[:shop_id])
        sub_category = shop.sub_categories.find_by(id: params[:id])
        if sub_category
          @shop_products = shop.shop_products.normal.where(sub_category_id: sub_category.id).sorted.by_page(params[:page_num])
        end
      end

      # http://localhost:3000/api/v1/products/detail_category/:id
      params do
        requires :id, type: String
        requires :shop_id, type: String
        optional :page_num, type: String
      end
      get "detail_category/:id", jbuilder: 'v1/products/detail_category' do
        shop = Shop.normal.find_by(id: params[:shop_id])
        detail_category = shop.detail_categories.find_by(id: params[:id])
        if detail_category
          @shop_products = shop.shop_products.normal.where(detail_category_id: detail_category.id).sorted.by_page(params[:page_num])
        end
      end
    end
  end
end
