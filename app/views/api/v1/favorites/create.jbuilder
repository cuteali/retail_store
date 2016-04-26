if @favorite
  json.errcode 0
  json.errmsg '添加收藏成功'
  json.id @favorite.id
else
  json.errcode 1
  json.errmsg '添加收藏失败'
end