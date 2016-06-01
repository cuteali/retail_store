class UserAgreementsController < ApplicationController
  skip_before_filter :filter_current_user
  skip_before_filter :current_shop
  layout false

  def index
  end
end
