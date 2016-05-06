if @order && @carts
  json.errcode 0
  json.errmsg '订单创建成功'
  json.obj do
    json.id @order.id
    json.address_id @order.address_id
  end
elsif @stock_volume_result == 3
  json.errcode 3
  json.errmsg '产品库存不足'
else
  json.errcode 1
  json.errmsg '订单创建失败'
  json.obj do
  end
end