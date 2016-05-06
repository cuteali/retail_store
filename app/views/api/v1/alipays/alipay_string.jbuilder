if @pay_url
  json.errcode 0
  json.errmsg '获取支付宝接口成功'
  json.obj do
    json.pay_url @pay_url
  end
else
  json.errcode 1
  json.errmsg '获取支付宝接口失败'
  json.obj do
  end
end