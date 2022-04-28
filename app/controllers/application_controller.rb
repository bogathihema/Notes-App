class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :info, :error, :warning, :success

  helper_method :current_user
  helper_method :logged_in?
  before_action :authorized

  def current_user
    User.find_by(id: session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end

  def authorized
    redirect_to '/welcome' unless logged_in?
  end
end
