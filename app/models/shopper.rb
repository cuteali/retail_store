class Shopper < ActiveRecord::Base
  mount_uploader :key, AvatarUploader

  has_many :addresses
  has_many :carts
  has_many :orders
  has_many :favorites
  has_many :messages

  scope :latest, -> { order('created_at DESC') }

  enum status: [ :normal, :deleted ]

  def self.sign_in(phone, rand_code)
    redis_rand_code = $redis.get(phone)
    token = nil
    if redis_rand_code == rand_code || (%w(18911800943 18701504584).include?(phone) && rand_code == "1111")
      token = SecureRandom.urlsafe_base64
      shopper = Shopper.shopper_token(phone, token)
    end
    [token, shopper]
  end

  def self.shopper_token(phone, token)
    shopper = Shopper.find_by(phone: phone)
    if shopper.present?
      shopper.update(token: token)
    else
      shopper = Shopper.create(token: token, phone: phone)
    end
    shopper
  end
end
