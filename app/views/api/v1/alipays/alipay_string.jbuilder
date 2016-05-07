if @is_expiration
  json.errcode 1
  json.errmsg '支付失败，订单已过期'
  json.obj do
  end
elsif @pay_url
  json.errcode 0
  json.errmsg '获取支付宝接口成功'
  json.obj do
    json.order_info @pay_url
  end
else
  json.errcode 1
  json.errmsg '获取支付宝接口失败'
  json.obj do
  end
end