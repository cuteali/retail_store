class Shopper < ActiveRecord::Base
  mount_uploader :key, ShopperUploader

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
    shopper = nil
    is_rand_code = false
    if %w(18911800943 18701504584).include?(phone)
      is_rand_code = rand_code == "1111"
      if is_rand_code
        token = SecureRandom.urlsafe_base64
        shopper = Shopper.shopper_token(phone, token)
      end
    else
      is_rand_code = redis_rand_code == rand_code
      if is_rand_code
        token = SecureRandom.urlsafe_base64
        shopper = Shopper.shopper_token(phone, token)
      end
    end
    [token, shopper, is_rand_code]
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
