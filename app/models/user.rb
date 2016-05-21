class User < ActiveRecord::Base
  attr_accessor :login

  belongs_to :shop

  validates :username,
  presence: true,
  uniqueness: {
    message: '用户名不能重复',
    case_sensitive: false
  }
  validates :phone,
  presence: true,
  uniqueness: {
    message: '手机号不能重复',
    case_sensitive: false
  }

  enum status: [ :normal, :deleted ]
  enum role: [:user, :editor, :admin]
  after_initialize :set_default_role, :if => :new_record?
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
         :validatable, :authentication_keys => [:login]

  scope :android, -> { where(client_type: 'android') }
  scope :ios, -> { where(client_type: 'ios') }

  def self.sign_in(value, password)
    token = nil
    user = User.find_by(username: value)
    user ||= User.find_by(phone: value)
    if user && user.valid_password?(password)
      token = SecureRandom.urlsafe_base64
      user.update(token: token)
    end
    [token, user]
  end

  def set_default_role
    self.role ||= :user
  end

  def role_name
    if user?
      return '店铺管理员'
    elsif editor?
      return '高级管理员'
    elsif admin?
      return '超级管理员'
    end
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(phone) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:phone) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end
end
