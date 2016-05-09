if @token
  if @result
    json.errcode 0
    json.errmsg '设备号更新成功'
  else
    json.errcode 1
    json.errmsg '设备号更新失败'
  end
else
  json.errcode 2
  json.errmsg '登录已过期，请重新登录'
end