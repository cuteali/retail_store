require 'net/http'
require 'uri'
module Sms
  def self.send_sms(mobiles, text, rand=nil)
    AppLog.info("mobiles: #{mobiles}")
    params = {}
    #修改为您的apikey.可在官网（http://www.yuanpian.com)登录后用户中心首页看到
    apikey = '7c5ab5d6099fdaa4424fd0ad8ca29388'
    #指定模板发送接口HTTP地址
    send_sms_uri = URI.parse('https://sms.yunpian.com/v1/sms/send.json')
    params['apikey'] = apikey
    #修改为您要发送的手机号码，多个号码用逗号隔开
    params['mobile'] = mobiles.join(',')
    params['text'] = text

    response = Net::HTTP.post_form(send_sms_uri, params)
    response = JSON.parse(response.body)
    AppLog.info("response:  #{response}")
    if response["code"] == 0
      if rand
        mobiles.each do |mobile|
          $redis.set(mobile, rand)
          $redis.expire(mobile, 1800)
          AppLog.info("#{$redis.get(mobile)}")
        end
      end
    end
    response["code"]
  end

  def self.rand_code
    newpass = ""
    1.upto(4){ |i| newpass << rand(10).to_s}
    return newpass
  end
end
