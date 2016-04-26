if @uptoken
  json.errcode 0
  json.errmsg '七牛token获取成功，有效期30分钟'
  json.obj do
    json.token @uptoken
  end
else
  json.errcode 1
  json.errmsg '七牛token获取失败'
  json.obj do
    json.token ''
  end
end