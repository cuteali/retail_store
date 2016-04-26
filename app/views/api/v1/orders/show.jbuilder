if @order
  json.errcode 0
  json.errmsg '获取订单详情成功'
  json.obj do
    json.id @order.id
    json.order_no @order.order_no
    json.payment @order.payment_name
    json.area @order.address.area
    json.detail @order.address.detail
    json.receive_name @order.address.receive_name
    json.receive_phone @order.address.receive_phone
    json.created_at @order.created_at.strftime("%Y-%m-%d %H:%M:%S")
    json.delivery_at @order.delivery_at.present?? @order.delivery_at.strftime("%Y-%m-%d %H:%M:%S") : ""
    json.complete_at @order.complete_at.present?? @order.complete_at.strftime("%Y-%m-%d %H:%M:%S") : ""
    json.pro_count @order.orders_shop_products.count
    json.productlist(@shop_products) do |op|
      json.product_id op.shop_product_id
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
  json.errmsg '获取订单详情失败'
  json.obj do
  end
end
