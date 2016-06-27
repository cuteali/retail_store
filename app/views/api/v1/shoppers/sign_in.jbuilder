if @result
  json.errcode 0
  json.errmsg '登录成功'
  json.obj do
    json.token @token
  end
else
  json.errcode 1
  if @shopper.blank?
    json.errmsg '手机号不正确'
  elsif !@is_rand_code
    json.errmsg '验证码不正确'
  else
    json.errmsg '登录失败'
  end
  json.obj do
    json.token ''
  end
end