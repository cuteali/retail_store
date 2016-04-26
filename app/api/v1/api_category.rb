module V1
  class ApiCategory < Grape::API

    version 'v1', using: :path

    resources 'categories' do
      # http://localhost:3000/api/v1/categories
      params do
        requires :shop_id, type: String
        optional :category_id, type: String
      end
      get '', jbuilder: 'v1/categories/index' do
        shop = Shop.normal.find_by(id: params[:shop_id])
        @categories = shop.categories.normal.sorted
        @category = shop.categories.normal.find_by(id: params[:category_id])
        @category ||= @categories.first
      end

      # http://localhost:3000/api/v1/categories/sub_categories
      params do
        requires :shop_id, type: String
        requires :category_id, type: String
      end
      get 'sub_categories', jbuilder: 'v1/categories/sub_categories' do
        shop = Shop.normal.find_by(id: params[:shop_id])
        category = shop.categories.normal.find_by(id: params[:category_id])
        @sub_categories = shop.sub_categories.normal.where(category_id: category.try(:id)).sorted
      end
    end
  end
end
