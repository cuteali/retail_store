module V1
  class ApiShopper < Grape::API

    version 'v1', using: :path

    resources 'shoppers' do
      # http://localhost:3000/api/v1/shoppers/send_sms
      params do
        requires :phone, type: String
      end
      post 'send_sms', jbuilder: "v1/shoppers/send_sms" do
        rand = Sms.rand_code
        text = "【醉食汇】您的验证码是#{rand}。如非本人操作，请忽略本短信！"
        @errcode = Sms.send_sms(params[:phone].split(/,/), text, rand)
        AppLog.info("info:#{@errcode}")
      end

      #http://localhost:3000/api/v1/shoppers/sign_in
      params do
        requires :phone, type: String
        requires :rand_code, type: String
      end
      post 'sign_in', jbuilder: "v1/shoppers/sign_in" do
        @token, @shopper, @is_rand_code = Shopper.sign_in(params[:phone], params[:rand_code])
        if @token.present?
          $redis.set(@shopper.id, @token)
          @result = $redis.expire(@shopper.id, 24*3600*15)
        end
      end

      #http://localhost:3000/api/v1/shoppers
      params do
        requires :token, type: String
        optional :name, type: String
        optional :key, type: String
      end
      put '', jbuilder: "v1/shoppers/update" do 
        authenticate!
        if @token
          declared_params = declared(params, include_missing: false)
          @result = @current_user.update_columns(declared_params)
        end
      end

      #http://localhost:3000/api/v1/shoppers/update_token
      params do
        requires :token, type: String
      end
      post 'update_token', jbuilder: "v1/shoppers/update_token" do
        authenticate!
        if @token
          token = SecureRandom.urlsafe_base64
          @current_user.update(token: token)
          $redis.set(@current_user.id, token)
          @result = $redis.expire(@current_user.id, 24*3600*15)
        end
      end

      # http://localhost:3000/api/v1/shoppers/:token
      params do
        requires :token, type: String
        requires :shop_id, type: String
      end
      get ':token', jbuilder: 'v1/shoppers/show' do
        authenticate!
        if @token
          shop = Shop.normal.find_by(id: params[:shop_id])
          @messages = @current_user.messages.where(shop_id: shop.id).normal.unread
        end
      end

      # http://localhost:3000/api/v1/shoppers/client/:token
      params do
        requires :token, type: String
        requires :client_id, type: String
        requires :client_type, type: String
      end
      get 'client/:token', jbuilder: 'v1/shoppers/client' do
        authenticate!
        if @token
          @result = @current_user.update(client_id: params[:client_id], client_type: params[:client_type])
        end
      end
    end
  end
end
