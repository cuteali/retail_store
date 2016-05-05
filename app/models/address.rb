class Address < ActiveRecord::Base
  belongs_to :shopper

  enum status: [ :normal, :deleted ]
  scope :default, -> { where(is_default: true) }

  def is_default_to_i
    is_default ? '1' : '0'
  end
end
