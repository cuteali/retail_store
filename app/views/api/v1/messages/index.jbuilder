if @token
  if @messages
    json.errcode 0
    json.errmsg '获取消息提示成功'
    json.total_pages @messages.total_pages if params[:page_num]
    json.objlist(@messages) do |message|
      json.id message.id
      json.shop_id message.shop.id
      json.title message.title
      json.info message.info
      json.is_new message.is_new_to_i
      json.image message.messageable_type == 'ShopProduct' ? message.messageable.key.try(:url) : ''
      json.obj_id message.messageable_id
      json.obj_type message.obj_type
      json.time message.created_at.strftime("%Y-%m-%d %H:%M:%S")
    end
  else
    json.errcode 1
    json.errmsg '获取消息提示失败'
    json.objlist do
    end
  end
else
  json.errcode 2
  json.errmsg '登录已过期，请重新登录'
end
