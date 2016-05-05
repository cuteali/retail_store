if @top_searchs
  json.errcode 0
  json.errmsg '获取热门搜索成功'
  json.objlist(@top_searchs) do |top|
    json.id top.id
    json.name top.name
  end
else
  json.errcode 1
  json.errmsg '获取热门搜索失败'
  json.objlist do
  end
end