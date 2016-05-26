module ReferrerUrlToSession
  extend ActiveSupport::Concern

  included do
    before_filter :session_referrer, only: [:edit]
  end

  def session_referrer
    if action_name =~ /edit|show/
      session[:return_to] = request.referrer if request.referrer !~ /edit/
    end
  end
end
