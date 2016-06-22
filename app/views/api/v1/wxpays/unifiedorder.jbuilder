if @token
  if @is_expiration
    json.errcode 1
    json.errmsg '支付失败，订单已过期'
    json.obj do
    end
  elsif @pay_sign
    json.errcode 0
    json.errmsg '获取微信支付接口成功'
    json.obj do
      json.partnerId ENV['weixin_mch_id']
      json.prepayId @order.prepay_id
      json.package 'Sign=WXPay'
      json.nonceStr @order.nonce_str
      json.timeStamp Weixinpay.get_time_stamp
      json.sign @pay_sign
    end
  else
    json.errcode 1
    json.errmsg '获取微信支付接口失败'
    json.obj do
    end
  end
else
  json.errcode 2
  json.errmsg '登录已过期，请重新登录'
end
