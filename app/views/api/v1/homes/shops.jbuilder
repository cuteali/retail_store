if @shops
  json.errcode 0
  json.errmsg '获取门店列表成功'
  json.data do
    json.shops(@shops) do |shop|
      json.id shop.id
      json.name shop.name
      json.position shop.position
    end
  end
else
  json.errcode 1
  json.errmsg '获取门店列表失败'
  json.data do
    json.shops do
    end
  end
end