module V1
  class ApiHome < Grape::API

    version 'v1', using: :path

    helpers do
      def category_products(shop, categories)
        products = {}
        categories.each do |category|
          key = category.logo_key.try(:url) || category.name
          products[key] = shop.shop_products.normal.sold_on.is_index.where(category_id: category.id).take(6)
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
        @shops = Shop.normal.finished
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
          @button_categories = @shop.categories.normal.is_index.sorted
          @tag_categories = @shop.categories.normal.is_tag.sorted
          @products = category_products(@shop, @tag_categories)
        end
      end

      # http://localhost:3000/api/v1/homes/top_search
      get 'top_search', jbuilder: 'v1/homes/top_search' do
        @top_searchs = TopSearch.normal
      end
    end
  end
end
