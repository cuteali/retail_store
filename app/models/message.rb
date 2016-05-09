class Message < ActiveRecord::Base
  belongs_to :shop
  belongs_to :shopper
  belongs_to :messageable, polymorphic: true

  enum status: [ :normal, :deleted ]
  enum is_new: [ :unread, :read ]

  def self.push_to_single(client_id, text, title=nil)
    pusher = IGeTui.pusher(ENV['app_id'], ENV['app_key'], ENV['master_secret'])

    template = Message.create_template(text, title)

    # 创建单体消息
    single_message = IGeTui::SingleMessage.new
    single_message.data = template

    # 创建客户端对象
    client = IGeTui::Client.new(client_id)

    # 发送一条通知到指定的客户端
    ret = pusher.push_message_to_single(single_message, client)
    Rails.logger.info "============#{ret}============"
  end

  def self.push_to_app(text, title=nil)
    pusher = IGeTui.pusher(ENV['app_id'], ENV['app_key'], ENV['master_secret'])

    template = Message.create_template(text, title)

    # 创建APP群发消息
    app_message = IGeTui::AppMessage.new
    app_message.data = template
    app_message.app_id_list = [ENV['app_id']]

    # 发送一条通知到程序
    ret = pusher.push_message_to_app(app_message)
    Rails.logger.info "============#{ret}============"
  end

  def self.create_template(text, title=nil)
    # 创建通知模板
    template = IGeTui::NotificationTemplate.new
    template.logo = '醉食汇logo.png'
    template.logo_url = 'http://7xszen.com2.z0.glb.qiniucdn.com/%E9%86%89%E9%A3%9F%E6%B1%87logo.png'
    template.title = title || '醉食汇'
    template.text = text
    template
  end
end
