if @order
  json.errcode 0
  json.errmsg '确认收货成功'
else
  json.errcode 1
  json.errmsg '确认收货失败'
end
