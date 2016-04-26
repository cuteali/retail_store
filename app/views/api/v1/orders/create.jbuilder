if @order && @carts
  json.errcode 0
  json.errmsg '订单创建成功'
elsif @stock_num_result == 3
  json.errcode 3
  json.errmsg '产品库存不足'
else
  json.errcode 1
  json.errmsg '订单创建失败'
  json.objlist do
  end
end
