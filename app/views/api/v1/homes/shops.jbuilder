if @shops
  json.errcode 0
  json.errmsg '获取门店列表成功'
  json.objlist(@shops) do |shop|
    json.id shop.id
    json.name shop.name
    json.lng shop.lng
    json.lat shop.lat
    json.address shop.address
  end
else
  json.errcode 1
  json.errmsg '获取门店列表失败'
  json.objlist do
  end
end