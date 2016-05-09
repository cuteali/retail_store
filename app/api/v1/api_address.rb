module V1
  class ApiAddress < Grape::API

    version 'v1', using: :path

    helpers do
      def is_default(default)
        default == '1' ? true : false
      end

      def update_all_default
        @current_user.addresses.update_all(is_default: false)
      end
    end

    resources 'addresses' do
      # http://localhost:3000/api/v1/addresses
      params do
        requires :token, type: String
      end
      get '', jbuilder: 'v1/addresses/index' do
        authenticate!
        if @token
          @addresses = @current_user.addresses.normal
        end
      end

      # http://localhost:3000/api/v1/addresses
      params do
        requires :token, type: String
        requires :receive_name, type: String
        requires :receive_phone, type: String
        requires :area, type: String
        requires :detail, type: String
        requires :lng, type: String
        requires :lat, type: String
        optional :default, type: String
      end
      post '', jbuilder: 'v1/addresses/create' do
        authenticate!
        if @token
          default = is_default(params[:default])
          update_all_default if default
          @address = @current_user.addresses.create(receive_phone: params[:receive_phone], receive_name: params[:receive_name], area: params[:area], detail: params[:detail], lng: params[:lng], lat: params[:lat], is_default: default)
        end
      end

      # http://localhost:3000/api/v1/addresses
      params do
        requires :token, type: String
        requires :id, type: String
        requires :receive_name, type: String
        requires :receive_phone, type: String
        requires :area, type: String
        requires :detail, type: String
        requires :lng, type: String
        requires :lat, type: String
        optional :default, type: String
      end
      put '', jbuilder: 'v1/addresses/update' do
        authenticate!
        if @token
          @address = @current_user.addresses.normal.find_by(id: params[:id])
          if @address.present?
            default = is_default(params[:default])
            update_all_default if default
            @is_updated = @address.update_columns(receive_phone: params[:receive_phone], receive_name: params[:receive_name], area: params[:area], detail: params[:detail], lng: params[:lng], lat: params[:lat], is_default: default)
          end
        end
      end

      #http://localhost:3000/api/v1/addresses
      params do 
        requires :token, type: String
        requires :id, type: String
      end
      delete '', jbuilder: 'v1/addresses/delete' do
        authenticate!
        if @token
          address = @current_user.addresses.normal.find_by(id: params[:id])
          if address.present?
            @address = address.deleted!
          end
        end
      end

      #http://localhost:3000/api/v1/addresses/show/:id
      params do 
        requires :token, type: String
        requires :id, type: String
      end
      get 'show/:id', jbuilder: 'v1/addresses/show' do
        AppLog.info("address show start")
        authenticate!
        if @token
          @address = @current_user.addresses.normal.find_by(id: params[:id])
        end
        AppLog.info("address:  #{@address}")
      end

      #http://localhost:3000/api/v1/addresses/default/:token
      params do 
        requires :token, type: String
      end
      get 'default/:token', jbuilder: 'v1/addresses/show' do 
        authenticate!
        if @token
          @address = @current_user.addresses.normal.default.first
        end
      end
    end
  end
end
