class Image < ActiveRecord::Base
  belongs_to :menuable, polymorphic: true

  enum status: [ :normal, :deleted ]
end
