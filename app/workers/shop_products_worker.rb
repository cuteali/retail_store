class ShopProductsWorker
  include Sidekiq::Worker
  sidekiq_options :queue => 'product', :retry => false, :backtrace => true

  def perform(shop_id)
    shop = Shop.normal.find_by(id: shop_id)
    Category.init_shop_categories(shop)
    Product.init_shop_products(shop)
  end

end