class OrdersShopProduct < ActiveRecord::Base
  belongs_to :order
  belongs_to :shop_product

  enum status: [ :normal, :deleted ]

  def self.valid_is_changed(order_id, option_params)
    tmp = false
    option_params.each do |option|
      op = OrdersShopProduct.find_by(order_id: order_id, id: option[:id])
      if op.try(:product_num).to_i != option[:product_num].to_i || op.try(:product_price).to_f != option[:product_price].to_f
        tmp = true
        break
      end
    end
    return tmp
  end
end
