if @shop_token
  if @order
    json.errcode 0
    json.errmsg '获取订单详情成功'
    json.obj do
      json.id @order.id
      json.shop_id @order.shop.id
      json.shop_name @order.shop.name
      json.order_no @order.order_no
      json.order_type Order.order_types[@order.order_type]
      json.state @order.state_type
      json.area @order.area
      json.detail @order.detail
      json.receive_name @order.receive_name
      json.receive_phone @order.receive_phone
      json.created_at @order.created_at.strftime("%Y-%m-%d %H:%M:%S")
      json.delivery_at @order.delivery_at.present?? @order.delivery_at.strftime("%Y-%m-%d %H:%M:%S") : ""
      json.complete_at @order.complete_at.present?? @order.complete_at.strftime("%Y-%m-%d %H:%M:%S") : ""
      json.pro_count @order.orders_shop_products.sum(:product_num)
      json.total_price @order.total_price
      json.expiration_time @order.get_expiration_time
      json.remarks @order.remarks
      json.freight @order.freight
      json.products(@shop_products) do |op|
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
else
  json.errcode 2
  json.errmsg '登录已过期，请重新登录'
end
