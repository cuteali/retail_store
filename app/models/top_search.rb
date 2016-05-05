class TopSearch < ActiveRecord::Base
  enum status: [ :normal, :deleted ]
end
