if @favorite
  json.errcode 0
  json.errmsg '添加收藏成功'
  json.obj do
    json.favorite_id @favorite.id
  end
else
  json.errcode 1
  json.errmsg '添加收藏失败'
  json.obj do
  end
end