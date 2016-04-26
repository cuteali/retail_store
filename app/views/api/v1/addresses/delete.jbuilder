if @address
  json.errcode 0
  json.errmsg '删除地址成功'
else
  json.errcode 1
  json.errmsg '删除地址失败'
end
