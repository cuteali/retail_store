if !@favorites.include?(false)
  json.errcode 0
  json.errmsg '清空收藏成功'
else
  json.errcode 1
  json.errmsg '清空收藏失败'
end
