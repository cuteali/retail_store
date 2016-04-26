if @shop_product
  json.errcode 0
  json.errmsg '获取产品详情成功'
  json.obj do
    json.id @shop_product.id
    json.name @shop_product.name
    json.image @shop_product.key.try(:url)
    json.unit @shop_product.unit.try(:name)
    json.price @shop_product.price
    json.old_price @shop_product.old_price
    json.stock_volume @shop_product.stock_volume
    json.sales_volume @shop_product.sales_volume
    json.desc @shop_product.desc
    json.info @shop_product.info
    json.spec @shop_product.spec
    json.favorites @favorite.present? ? 0 : 1
    json.favorite_id @favorite.present? ? @favorite.id : ''
  end
else
  json.errcode 1
  json.errmsg '获取产品详情失败'
  json.obj do
  end
end

