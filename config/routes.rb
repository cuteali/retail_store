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
    end
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
    collection do
      get :select_product, :search_product
    end
  end
  resources :shop_models
  resources :units
  resources :top_searches
  resources :adverts
end
