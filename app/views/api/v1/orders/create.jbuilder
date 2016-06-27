if @token
  if @order && @carts
    json.errcode 0
    json.errmsg '订单创建成功'
    json.obj do
      json.id @order.id
      json.address_id @order.address_id
    end
  elsif @not_enough_products.present?
    json.errcode 3
    json.errmsg "产品：#{@not_enough_products.join(',')} 库存不足"
  elsif @sold_off_products.present?
    json.errcode 1
    json.errmsg "产品：#{@sold_off_products.join(',')} 已下架"
  else
    json.errcode 1
    json.errmsg '订单创建失败'
    json.obj do
    end
  end
else
  json.errcode 2
  json.errmsg '登录已过期，请重新登录'
end
