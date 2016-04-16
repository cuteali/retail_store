if @uptoken
  json.errcode 0
  json.errmsg '七牛token获取成功，有效期30分钟'
  json.data do
    json.token @uptoken
  end
else
  json.errcode 1
  json.errmsg '七牛token获取失败'
  json.data do
    json.token ''
  end
end