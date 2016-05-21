module V1
  class ApiMessage < Grape::API

    version 'v1', using: :path

    resources 'messages' do
      # http://localhost:3000/api/v1/messages
      params do
        requires :token, type: String
        requires :shop_id, type: String
        optional :page_num, type: String
      end
      get '', jbuilder: 'v1/messages/index' do
        authenticate!
        if @token
          @messages = @current_user.messages.where(shop_id: params[:shop_id]).normal.latest.by_page(params[:page_num])
        end
      end

      # http://localhost:3000/api/v1/messages/is_read
      params do
        requires :token, type: String
        requires :id, type: String
      end
      get 'is_read', jbuilder: 'v1/messages/is_read' do
        authenticate!
        if @token
          message = @current_user.messages.normal.find_by(id: params[:id])
          if message.present?
            @message = message.update(is_new: 1)
          end
        end
      end

      #http://localhost:3000/api/v1/messages
      params do 
        requires :token, type: String
        requires :id, type: String
      end
      delete '', jbuilder: 'v1/messages/delete' do
        authenticate!
        if @token
          message = @current_user.messages.normal.find_by(id: params[:id])
          if message.present?
            @message = message.deleted!
          end
        end
      end

      #http://localhost:3000/api/v1/messages/delete_all
      params do 
        requires :token, type: String
        requires :shop_id, type: String
      end
      get 'delete_all', jbuilder: 'v1/messages/delete_all' do
        authenticate!
        if @token
          messages = @current_user.messages.normal.where(shop_id: params[:shop_id])
          if messages.present?
            @messages = messages.map{|m| m.deleted!}
          end
        end
      end
    end
  end
end
