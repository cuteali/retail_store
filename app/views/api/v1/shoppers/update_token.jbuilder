if @result
  json.errcode 0
  json.errmsg 'token更新成功'
  json.obj do
    json.token @token
  end
else
  json.errcode 1
  json.errmsg 'token更新失败'
  json.obj do
    json.token ''
  end
end