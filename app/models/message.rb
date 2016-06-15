class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :shop
  belongs_to :shopper
  belongs_to :messageable, polymorphic: true

  enum status: [ :normal, :deleted ]
  enum is_new: [ :unread, :read ]
  enum goal: [ :push_shopper, :push_user ]

  scope :latest, -> { order('created_at DESC') }
  scope :by_page, -> (page_num) { page(page_num) if page_num }
  scope :broadcast, -> { where("shopper_id is ?", nil) }

  def goal_name
    push_shopper? ? '用户端' : '商户端'
  end

  def shop_push_message
    if push_shopper?
      push_users = Shopper.normal
    elsif push_user?
      push_users = shop.users.normal
    end
    push_users.each do |obj|
      if obj.is_a?(User)
        message = obj.messages.create(shop_id: shop_id, messageable: messageable, title: title, info: info)
        message.push_to_user(obj)
      elsif obj.is_a?(Shopper)
        message = obj.messages.new(shop_id: shop_id, messageable: messageable, title: title, info: info)
        message.push_to_shopper(obj)
      end
    end
  end

  def push_to_user(obj)
    if obj.client_type == 'android'
      igetui_push_message_to_list(obj.client_id)
    elsif obj.client_type == 'ios'
      jpush_push_shop_message(obj.client_id)
    end
  end

  def push_to_shopper(obj)
    if obj.client_type == 'android'
      igetui_push_message(obj.client_id)
    elsif obj.client_type == 'ios'
      jpush_push_message(obj.client_id)
    end
  end

  def self.push_message_to_user(order)
    message = order.messages.new(title: '醉食汇', info: "您有一条新的订单！")
    order.shop.users.normal.each do |user|
      if user.client_type == 'android'
        message.igetui_push_message_to_list(user.client_id)
      elsif user.client_type == 'ios'
        message.jpush_push_shop_message(user.client_id)
      end
    end
  end

  def self.push_message_to_shopper(order)
    shopper = order.shopper
    message = order.messages.create(shopper_id: shopper.id, title: '醉食汇', info: "商家已接单！")
    if shopper.client_type == 'android'
      message.igetui_push_message(shopper.client_id)
    elsif shopper.client_type == 'ios'
      message.jpush_push_message(shopper.client_id)
    end
  end

  def is_new_to_i
    unread? ? '0' : '1'
  end

  def obj_type
    case messageable_type
    when 'ShopProduct' then '0'
    when 'Order' then '1'
    else
      '2'
    end
  end

  def igetui_push_message(client_id=nil)
    pusher = IGeTui.pusher(ENV['igetui_app_id'], ENV['igetui_app_key'], ENV['igetui_master_secret'])

    template = IGeTui::NotificationTemplate.new
    template.logo = '安卓512-512logo.png'
    template.logo_url = 'http://7xszen.com1.z0.glb.clouddn.com/%E5%AE%89%E5%8D%93512-512logo.png'
    template.title = title.blank? ? '醉食汇' : title
    template.text = info

    message = IGeTui::AppMessage.new
    message.data = template

    if client_id
      client = IGeTui::Client.new(client_id)
      ret = pusher.push_message_to_single(message, client)
    else
      message.app_id_list = [ENV['igetui_app_id']]
      ret = pusher.push_message_to_app(message)
    end
    Rails.logger.info "============#{ret}============"
  end

  def igetui_push_message_to_list(client_id=nil)
    pusher = IGeTui.pusher(ENV['igetui_shop_app_id'], ENV['igetui_shop_app_key'], ENV['igetui_shop_master_secret'])

    # 创建一条透传消息
    template = IGeTui::TransmissionTemplate.new
    content = {
                action: 'notification',
                title: title.blank? ? '醉食汇' : title,
                content: info,
                type: obj_type,
                id: messageable_id.to_s
              }
    content = content.to_s.gsub(":", "").gsub("=>", ":")
    template.transmission_content = content

    list_message = IGeTui::ListMessage.new
    list_message.data = template

    client_list = []
    users = User.normal.android.where(client_id: client_id)
    users = User.normal.android if users.blank?
    users.each do |u|
      client = IGeTui::Client.new(u.client_id)
      client_list << client
    end

    content_id = pusher.get_content_id(list_message)
    ret = pusher.push_message_to_list(content_id, client_list)
    Rails.logger.info "============#{ret}============"
  end

  def jpush_push_message(registration_id=nil)
    jpush = JPush::Client.new(ENV['jpush_app_key'], ENV['jpush_master_secret'])

    pusher = jpush.pusher

    notification = JPush::Push::Notification.new
    notification.set_ios(
      alert: info.blank? ? '您有新的消息' : info,
      sound: 'default',
      badge: 1,
      available: true,
      extras: {obj_id: messageable_id, obj_type: messageable_type}
    )

    if registration_id
      audience = JPush::Push::Audience.new.set_registration_id(registration_id)
    end

    push_payload = JPush::Push::PushPayload.new(
      platform: 'ios',
      audience: audience || 'all',
      notification: notification
    ).set_message(
      info.blank? ? '您有新的消息' : info,
      title: title.blank? ? '醉食汇' : title
    ).set_options(
      apns_production: true
    )
    ret = pusher.push(push_payload) rescue nil
    Rails.logger.info "============#{ret}============"
  end

  def jpush_push_shop_message(registration_id=nil)
    jpush = JPush::Client.new(ENV['jpush_shop_app_key'], ENV['jpush_shop_master_secret'])

    pusher = jpush.pusher

    notification = JPush::Push::Notification.new
    notification.set_ios(
      alert: info.blank? ? '您有新的消息' : info,
      sound: 'default',
      badge: 1,
      available: true,
      extras: {obj_id: messageable_id, obj_type: messageable_type}
    )

    if registration_id
      audience = JPush::Push::Audience.new.set_registration_id(registration_id)
    end
    
    push_payload = JPush::Push::PushPayload.new(
      platform: 'ios',
      audience: audience || 'all',
      notification: notification
    ).set_message(
      info.blank? ? '您有新的消息' : info,
      title: title.blank? ? '醉食汇' : title
    ).set_options(
      apns_production: true
    )
    ret = pusher.push(push_payload) rescue nil
    Rails.logger.info "============#{ret}============"
  end
end
