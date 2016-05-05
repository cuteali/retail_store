class Message < ActiveRecord::Base
  belongs_to :shop
  belongs_to :shopper
  belongs_to :messageable, polymorphic: true

  enum status: [ :normal, :deleted ]
  enum is_new: [ :unread, :read ]
end
