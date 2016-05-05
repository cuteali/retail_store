if @shop_products
  json.errcode 0
  json.errmsg '搜索产品成功'
  json.total_pages @shop_products.total_pages if params[:page_num]
  json.objlist(@shop_products) do |product|
    json.id product.id
    json.name product.name
    json.image product.key.try(:url)
    json.unit product.unit.try(:name)
    json.price product.price
    json.old_price product.old_price
    json.stock_volume product.stock_volume
    json.sales_volume product.sales_volume
    json.spec product.spec
  end
else
  json.errcode 1
  json.errmsg '搜索产品失败'
  json.objlist(@top_shop_products) do |product|
    json.id product.id
    json.name product.name
    json.image product.key.try(:url)
    json.unit product.unit.try(:name)
    json.price product.price
    json.old_price product.old_price
    json.stock_volume product.stock_volume
    json.sales_volume product.sales_volume
    json.spec product.spec
  end
end
