class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_current_user

  def set_current_user
    @current_user = User.first
  end

  def current_user
    @current_user
  end

  helper_method :current_user
end
