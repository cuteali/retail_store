Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }

  root to: "home#index"

  mount API => '/'

  resources :home, only: :index do
    collection do
      post :upload_xls
    end
  end

  resources :orders do
    collection do
      post :alipay_notify
      post :add_order_product
      get :select_product, :change_is_receiving
    end
    delete :delete_order_product, on: :member
  end

  resources :categories do
    member do
      get :stick_top
    end
    collection do
      get :select_options
    end
  end

  resources :sub_categories do
    member do
      get :stick_top
    end
  end

  resources :detail_categories do
    member do
      get :stick_top
    end
  end

  resources :products do
    post :upload_images
    delete :delete_image, on: :member
  end

  resources :shops do
    member do
      get :init_categories_products
    end
  end

  resources :users do
    member do
      get :forget_password
      put :reset_password
    end
  end

  resources :shop_products do
    post :upload_images
    collection do
      get :select_product, :search_product
    end
    member do
      get :stick_top
      delete :delete_image
    end
  end

  resources :shop_models
  resources :units
  resources :top_searches
  resources :adverts
  resources :shoppers
  resources :addresses
  resources :messages
end
