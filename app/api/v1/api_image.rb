module V1
  class ApiImage < Grape::API

    version 'v1', using: :path

    resources 'images' do
      # http://localhost:3000/api/v1/images/uptoken
      get 'uptoken', jbuilder: 'v1/images/uptoken' do
        @uptoken = Image.uptoken
      end
    end
  end
end
