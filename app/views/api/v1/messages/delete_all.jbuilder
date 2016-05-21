if @token
  if !@messages.include?(false)
    json.errcode 0
    json.errmsg '清空消息成功'
  else
    json.errcode 1
    json.errmsg '清空消息失败'
  end
else
  json.errcode 2
  json.errmsg '登录已过期，请重新登录'
end
