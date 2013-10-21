class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :verify_is_admin

  helper_method :current_user

  private
  def verify_is_admin
    (current_user.nil?) ? redirect_to(root_path) : (redirect_to(root_path) unless current_user.admin?)
  end

  def current_user
    @current_user ||= User.find(session[:UserID]) if session[:UserID]
  end

end
