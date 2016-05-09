if @token
  if @current_user
    json.errcode 0
    json.errmsg '用户信息获取成功'
    json.obj do
      json.id @current_user.id
      json.name @current_user.name
      json.image @current_user.key.try(:url).to_s
      json.phone @current_user.phone
      json.is_new_msg @messages.present? ? '0' : '1'
    end
  else
    json.errcode 1
    json.errmsg '用户信息获取失败'
  end
else
  json.errcode 2
  json.errmsg '登录已过期，请重新登录'
end
