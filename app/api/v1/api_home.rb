module V1
  class ApiHome < Grape::API

    version 'v1', using: :path

    helpers do
      def category_products(shop, categories)
        products = {}
        categories.each do |category|
          products[category.name] = shop.shop_products.app_index.where(category_id: category.id)
        end
        products
      end
    end

    resources 'homes' do
      # http://localhost:3000/api/v1/homes
      params do
        requires :version, type: String
      end
      get '', jbuilder: 'v1/homes/index' do
        @version = params[:version]
      end

      # http://localhost:3000/api/v1/homes/shops
      get 'shops', jbuilder: 'v1/homes/shops' do
        @shops = Shop.normal
      end

      # http://localhost:3000/api/v1/homes/contents
      params do
        optional :shop_id, type: String
      end
      get 'contents', jbuilder: 'v1/homes/contents' do
        @shop = Shop.normal.find_by(id: params[:shop_id])
        @shop ||= Shop.normal.first
        if @shop
          @adverts = @shop.adverts.normal
          @categories = Category.normal.sorted
          @products = category_products(@shop, @categories)
        end
      end
    end
  end
end
