if @orders
  json.errcode 0
  json.errmsg '获取订单列表成功'
  json.objlist(@orders) do |order|
    json.id order.id
    json.shop_id order.shop.id
    json.shop_name order.shop.name
    json.order_no order.order_no
    json.state order.state_type
    json.area order.area
    json.detail order.detail
    json.receive_name order.receive_name
    json.receive_phone order.receive_phone
    json.created_at order.created_at.strftime("%Y-%m-%d %H:%M:%S")
    json.delivery_at order.delivery_at.present?? order.delivery_at.strftime("%Y-%m-%d %H:%M:%S") : ""
    json.complete_at order.complete_at.present?? order.complete_at.strftime("%Y-%m-%d %H:%M:%S") : ""
    json.pro_count order.orders_shop_products.sum(:product_num)
    json.total_price order.total_price
    json.expiration_time order.get_expiration_time
    json.products(order.orders_shop_products) do |op|
      json.id op.shop_product_id
      json.number op.product_num
      json.name op.shop_product.name
      json.image op.shop_product.key.try(:url)
      json.unit op.shop_product.unit.present? ? op.shop_product.unit.name : ""
      json.stock_volume op.shop_product.stock_volume
      json.sales_volume op.shop_product.sales_volume
      json.price op.shop_product.price
      json.old_price op.shop_product.old_price
      json.desc op.shop_product.desc
      json.info op.shop_product.info
      json.spec op.shop_product.spec
    end
  end
else
  json.errcode 1
  json.errmsg '获取订单列表失败'
  json.objlist do
  end
end
