if @token
  if @result
    json.errcode 0
    json.errmsg '用户信息更新成功'
    json.obj do
      json.id @current_user.id
      json.name @current_user.name
      json.image @current_user.key.try(:url)
      json.phone @current_user.phone
    end
  else
    json.errcode 1
    json.errmsg '用户信息更新失败'
    json.obj do
    end
  end
else
  json.errcode 2
  json.errmsg '登录已过期，请重新登录'
end
