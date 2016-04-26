if @favorite
  json.errcode 0
  json.errmsg '删除收藏成功'
else
  json.errcode 1
  json.errmsg '删除收藏失败'
end
