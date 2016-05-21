class ApplicationController < ActionController::Base
  include ApplicationHelper
  include ReferrerUrlToSession
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_filter :current_shop

  def current_shop
    @shop = current_user.shop
  end

  def update_keys(model, key_params, logo_key_params=nil)
    key_params.to_a.each do |k|
      model.update(key: k)
    end
    logo_key_params.to_a.each do |k|
      model.update(logo_key: k)
    end
  end

  private

    def user_not_authorized
      flash[:warning] = "你未被授权执行该操作。"
      redirect_to(request.referrer || root_path)
    end

  protected

    def configure_permitted_parameters
      added_attrs = [:shop_id, :role, :username, :phone, :email, :password, :password_confirmation, :remember_me]
      devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
      devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    end
end
