if @address
  json.errcode 0
  json.errmsg '获取地址详情成功'
  json.obj do
    json.id @address.id
    json.area @address.area
    json.detail @address.detail
    json.receive_name @address.receive_name
    json.receive_phone @address.receive_phone
    json.default @address.is_default_to_i
  end
else
  json.errcode 1
  json.errmsg '获取地址详情失败'
  json.obj do
  end
end
