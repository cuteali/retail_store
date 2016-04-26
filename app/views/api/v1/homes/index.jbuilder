json.errcode 0
json.errmsg '获取基本信息'
json.obj do
  json.version 1
  if @version == '0'
    json.send_price 0
    json.phone_num '400-0050-383'
  end
end