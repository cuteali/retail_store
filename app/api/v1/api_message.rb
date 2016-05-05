module V1
  class ApiMessage < Grape::API

    version 'v1', using: :path

    resources 'messages' do
      # http://localhost:3000/api/v1/messages
      params do
        requires :token, type: String
      end
      get '', jbuilder: 'v1/messages/index' do
        authenticate!
        if !@erruser 
          @messages = @current_user.messages.normal
        end
      end
    end
  end
end
