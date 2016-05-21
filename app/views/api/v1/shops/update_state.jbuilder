if @shop_token
  if @order
    json.errcode 0
    json.errmsg @msg
  else
    json.errcode 1
    json.errmsg '请求失败'
  end
else
  json.errcode 2
  json.errmsg '登录已过期，请重新登录'
end
