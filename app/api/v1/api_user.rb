module V1
  class ApiUser < Grape::API

    version 'v1', using: :path

    resources 'users' do
      #http://localhost:3000/api/v1/users/sign_in
      params do
        requires :username, type: String
        requires :password, type: String
      end
      post 'sign_in', jbuilder: "v1/users/sign_in" do
        @shop_token, @user = User.sign_in(params[:username], params[:password])
        if @shop_token.present?
          key = "#{@user.username}_#{@user.phone}"
          $redis.set(key, @shop_token)
          @result = $redis.expire(key, 24*3600*15)
        end
      end

      #http://localhost:3000/api/v1/users/update_token
      params do
        requires :token, type: String
      end
      post 'update_token', jbuilder: "v1/users/update_token" do
        authenticate_shop!
        if @shop_token
          token = SecureRandom.urlsafe_base64
          @current_shop.update(token: token)
          key = "#{@current_shop.username}_#{@current_shop.phone}"
          $redis.set(key, token)
          @result = $redis.expire(key, 24*3600*15)
        end
      end

      # http://localhost:3000/api/v1/users/client/:token
      params do
        requires :token, type: String
        requires :client_id, type: String
        requires :client_type, type: String
      end
      get 'client/:token', jbuilder: 'v1/users/client' do
        authenticate_shop!
        if @shop_token
          @result = @current_shop.update(client_id: params[:client_id], client_type: params[:client_type])
        end
      end
    end
  end
end
