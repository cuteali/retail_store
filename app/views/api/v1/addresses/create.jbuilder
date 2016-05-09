if @token
  if @address
    json.errcode 0
    json.errmsg '新建地址成功'
    json.obj do
      json.id @address.id
      json.area @address.area
      json.detail @address.detail
      json.lng @address.lng
      json.lat @address.lat
      json.receive_name @address.receive_name
      json.receive_phone @address.receive_phone
      json.is_default @address.is_default_to_i
    end
  else
    json.errcode 1
    json.errmsg '新建地址失败'
    json.obj do
    end
  end
else
  json.errcode 2
  json.errmsg '登录已过期，请重新登录'
end
