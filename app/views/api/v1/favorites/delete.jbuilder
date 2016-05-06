if @favorite
  json.errcode 0
  json.errmsg '取消收藏成功'
else
  json.errcode 1
  json.errmsg '取消收藏失败'
end
