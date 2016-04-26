class Address < ActiveRecord::Base
  belongs_to :shopper

  enum status: [ :normal, :deleted ]
  enum is_default: { is_default: true, not_default: false }

  def is_default_to_i
    is_default? ? '1' : '0'
  end
end
