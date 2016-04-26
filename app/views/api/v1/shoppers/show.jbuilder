if @erruser
  json.errcode 1
  json.errmsg '用户信息获取失败'
else
  json.errcode 0
  json.errmsg '用户信息获取成功'
  json.obj do
    json.id @current_user.id
    json.name @current_user.name
    json.image @current_user.key.try(:url).to_s
    json.phone @current_user.phone
  end
end
