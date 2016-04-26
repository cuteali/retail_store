if @result
  json.errcode 0
  json.errmsg '登录成功'
  json.obj do
    json.token @token
  end
else
  json.errcode 1
  json.errmsg '登录失败，手机或验证码不正确'
  json.obj do
    json.token ''
  end
end