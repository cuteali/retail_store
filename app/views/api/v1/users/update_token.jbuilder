if @shop_token
  if @result
    json.errcode 0
    json.errmsg 'token更新成功'
    json.obj do
      json.token @current_shop.token
    end
  else
    json.errcode 1
    json.errmsg 'token更新失败'
    json.obj do
      json.token ''
    end
  end
else
  json.errcode 2
  json.errmsg '登录已过期，请重新登录'
  json.obj do
    json.token ''
  end
end
