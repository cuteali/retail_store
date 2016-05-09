if @token
  if @favorites
    json.errcode 0
    json.errmsg '获取收藏宝贝成功'
    json.total_pages @favorites.total_pages if params[:page_num]
    json.objlist(@favorites) do |favorite|
      json.id favorite.id
      json.product_id favorite.shop_product.id
      json.product_name favorite.shop_product.name
      json.product_image favorite.shop_product.key.try(:url)
      json.product_unit favorite.shop_product.unit.try(:name)
      json.product_price favorite.shop_product.price
      json.product_old_price favorite.shop_product.old_price
      json.product_stock_volume favorite.shop_product.stock_volume
      json.product_sales_volume favorite.shop_product.sales_volume
      json.product_spec favorite.shop_product.spec
    end
  else
    json.errcode 1
    json.errmsg '获取收藏宝贝失败'
    json.objlist do
    end
  end
else
  json.errcode 2
  json.errmsg '登录已过期，请重新登录'
end
