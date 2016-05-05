if @messages
  json.errcode 0
  json.errmsg '获取消息提示成功'
  json.objlist(@messages) do |message|
    json.id message.id
    json.shop_id message.shop.id
    json.title message.title
    json.info message.info
    json.is_new message.is_new
  end
else
  json.errcode 1
  json.errmsg '获取消息提示失败'
  json.objlist do
  end
end
