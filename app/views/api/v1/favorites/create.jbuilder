if @token
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
else
  json.errcode 2
  json.errmsg '登录已过期，请重新登录'
end
  