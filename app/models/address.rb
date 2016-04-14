class Address < ActiveRecord::Base
  belongs_to :shopper

  enum status: [ :normal, :deleted ]
end
