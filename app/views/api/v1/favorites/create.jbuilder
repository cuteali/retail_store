if @favorite
  json.errcode 0
  json.errmsg '添加收藏成功'
  json.obj do
    json.id @favorite.id
  end
else
  json.errcode 1
  json.errmsg '添加收藏失败'
  json.obj do
  end
end