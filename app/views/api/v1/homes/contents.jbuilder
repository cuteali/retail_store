if @shop
  json.errcode 0
  json.errmsg '获取首页内容成功'
  json.obj do
    json.advertlist(@adverts) do |advert|
      json.id advert.id
      json.shop_id advert.shop_id
      json.shop_product_id advert.shop_product_id
      json.image advert.key.try(:url)
    end
    json.categorylist(@button_categories) do |category|
      json.id category.id
      json.name category.name_as
      json.image category.key.try(:url)
    end
    json.productlist(@products) do |key, values|
      json.image key if key != '0'
      json.set! 'list' do
        json.array! values do |product|
          json.id product.id
          json.name product.name
          json.image product.key.try(:url)
          json.unit product.unit.try(:name)
          json.price product.price
          json.old_price product.old_price
          json.stock_volume product.stock_volume
          json.sales_volume product.sales_volume
          json.spec product.spec
          json.title '特价'
        end
      end
    end
  end
else
  json.errcode 1
  json.errmsg '获取首页内容失败'
  json.obj do
    json.advertlist do
    end
    json.categorylist do
    end
    json.productlist do
    end
  end
end
