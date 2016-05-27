class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :shop
  belongs_to :shopper
  belongs_to :messageable, polymorphic: true

  enum status: [ :normal, :deleted ]
  enum is_new: [ :unread, :read ]

  scope :latest, -> { order('created_at DESC') }
  scope :by_page, -> (page_num) { page(page_num) if page_num }

  def self.push_message_to_user(order)
    message = order.messages.new(title: '您有新的订单！', info: "醉食汇订单：#{order.order_no}")
    order.shop.users.normal.each do |user|
      if user.client_type == 'android'
        message.igetui_push_message_to_list(user.client_id)
      elsif user.client_type == 'ios'
        message.jpush_push_message(user.client_id)
      end
    end
  end

  def self.push_message_to_shopper(order)
    shopper = order.shopper
    message = order.messages.create(shopper_id: shopper.id, title: '商家已接单', info: "醉食汇订单：#{order.order_no}")
    if shopper.client_type == 'android'
      message.igetui_push_message_to_list(shopper.client_id)
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
      ''
    end
  end

  def igetui_push_message(client_id=nil)
    pusher = IGeTui.pusher(ENV['igetui_app_id'], ENV['igetui_app_key'], ENV['igetui_master_secret'])

    template = IGeTui::NotificationTemplate.new
    template.logo = '醉食汇logo.png'
    template.logo_url = 'http://7xszen.com2.z0.glb.qiniucdn.com/%E9%86%89%E9%A3%9F%E6%B1%87logo.png'
    template.title = title || '醉食汇'
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
                title: title || '醉食汇',
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
      alert: info,
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
      info,
      title: title || '醉食汇'
    ).set_options(
      apns_production: true
    )
    ret = pusher.push(push_payload)
    Rails.logger.info "============#{ret}============"
  end
end
