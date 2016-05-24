class ShopProductsController < ApplicationController

  def select_product
    product = @shop.shop_products.normal.find_by(id: params[:product_id])
    html = get_select_product_html(product)
    render json: {html: html, product_id: product.id}
  end

  def search_product
    options = @shop.shop_products.normal.where("name like ?", "%#{params[:product_name]}%").sorted
    html = get_select_category_html(options, params[:id], params[:name], params[:first_option])
    render json: {html: html}
  end
end
