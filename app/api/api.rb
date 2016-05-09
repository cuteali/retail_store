class API < Grape::API
  prefix 'api'
  format :json
  formatter :json, Grape::Formatter::Jbuilder

  helpers do
    def current_user
      user_token = params.delete(:token)
      AppLog.info("user_token:    #{user_token}")
      current_user = Shopper.normal.find_by(token: user_token)
      if current_user.present?
        AppLog.info("user_id : #{current_user.id}")
        token = $redis.get(current_user.id)
        AppLog.info("token is :#{token}")
      end
      [token, current_user]
    end

    def authenticate!
      @token, @current_user = current_user
    end
  end

  mount V1::ApiAddress
  mount V1::ApiAlipay
  mount V1::ApiCart
  mount V1::ApiCategory
  mount V1::ApiFavorite
  mount V1::ApiHome
  mount V1::ApiImage
  mount V1::ApiMessage
  mount V1::ApiOrder
  mount V1::ApiProduct
  mount V1::ApiShopper
end
