if @carts
  json.errcode 0
  json.errmsg '获取用户购物车成功'
  json.objlist(@carts) do |key, values|
    json.category_name key
    json.set! 'list' do
      json.array! values do |cart|
        json.cart_id cart.id
        json.product_id cart.shop_product_id
        json.product_num cart.product_num
        json.product_name cart.shop_product.name
        json.product_image cart.shop_product.key.try(:url)
        json.product_unit cart.shop_product.unit.try(:name)
        json.product_price cart.shop_product.price
        json.product_old_price cart.shop_product.old_price
        json.product_stock_volume cart.shop_product.stock_volume
        json.product_sales_volume cart.shop_product.sales_volume
        json.product_spec cart.shop_product.spec
      end
    end
  end
else
  json.errcode 1
  json.errmsg '获取用户购物车失败'
  json.objlist do
  end
end
