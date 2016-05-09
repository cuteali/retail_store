if @token
  if @addresses
    json.errcode 0
    json.errmsg '获取用户地址成功'
    json.objlist(@addresses) do |address|
      json.id address.id
      json.area address.area
      json.detail address.detail
      json.lng address.lng
      json.lat address.lat
      json.receive_name address.receive_name
      json.receive_phone address.receive_phone
      json.is_default address.is_default_to_i
    end
  else
    json.errcode 1
    json.errmsg '获取用户地址失败'
    json.objlist do
    end
  end
else
  json.errcode 2
  json.errmsg '登录已过期，请重新登录'
end
