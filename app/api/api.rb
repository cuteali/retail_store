class API < Grape::API
  prefix 'api'
  format :json
  formatter :json, Grape::Formatter::Jbuilder

  helpers do
    def current_user
      shopper_id = $redis.get(params.delete(:token))
      @current_user ||= Shopper.normal.find_by(id: shopper_id)
    end

    def authenticate!
      @erruser = current_user.blank?
    end
  end

  mount V1::ApiAddress
  mount V1::ApiCart
  mount V1::ApiCategory
  mount V1::ApiFavorite
  mount V1::ApiHome
  mount V1::ApiImage
  mount V1::ApiOrder
  mount V1::ApiProduct
  mount V1::ApiShopper
end
