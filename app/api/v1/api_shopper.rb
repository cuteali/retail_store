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
        @token, @shopper = Shopper.sign_in(params[:phone], params[:rand_code])
        if @token.present?
          $redis.set(@token, @shopper.id)
          @result = $redis.expire(@token, 24*3600*15)
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
        if !@erruser
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
        if !@erruser
          @token = SecureRandom.urlsafe_base64
          $redis.del(@current_user.token)
          @current_user.update(token: @token)
          $redis.set(@token, @current_user.id)
          @result = $redis.expire(@token, 24*3600*15)
        end
      end

      # http://localhost:3000/api/v1/shoppers/:token
      params do
        requires :token, type: String
      end
      get ':token', jbuilder: 'v1/shoppers/show' do
        authenticate!
      end
    end
  end
end
