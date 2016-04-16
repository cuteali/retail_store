if @errcode == 0
  json.errcode 0
  json.errmsg '验证码发送成功'
else
  json.errcode 1
  json.errmsg '验证码发送失败'
end
