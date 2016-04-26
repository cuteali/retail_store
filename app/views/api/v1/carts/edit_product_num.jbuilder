if @cart
  json.errcode 0
  json.errmsg '修改产品数量成功'
else
  json.errcode 1
  json.errmsg '修改产品数量失败'
end