if @shop_product
  json.errcode 0
  json.errmsg '获取产品详情成功'
  json.obj do
    json.id @shop_product.id
    json.name @shop_product.name
    json.unit @shop_product.unit.try(:name)
    json.price @shop_product.price
    json.old_price @shop_product.old_price
    json.stock_volume @shop_product.stock_volume
    json.sales_volume @shop_product.sales_volume
    json.desc @shop_product.desc
    json.info @shop_product.info
    json.spec @shop_product.spec
    json.is_favorite @favorite.present? ? 0 : 1
    json.favorite_id @favorite.present? ? @favorite.id : ''
    json.imagelist(@images) do |image|
      json.image image.key.try(:url)
    end
    json.hotlists(@top_shop_products) do |product|
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
else
  json.errcode 1
  json.errmsg '获取产品详情失败'
  json.obj do
  end
end

