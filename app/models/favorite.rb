class Favorite < ActiveRecord::Base
  belongs_to :shop
  belongs_to :shopper
  belongs_to :shop_product

  enum status: [ :normal, :deleted ]

  scope :latest, -> { order('created_at DESC') }
  scope :by_page, -> (page_num) { page(page_num) if page_num }
end
