class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :check_logged_in?

  def after_sign_in_path_for(resource)
    return agencies_path if (current_user.role == "admin")

    root_path
  end

  private

  def check_logged_in?
    unless user_signed_in? && (current_user.role == "admin")
      redirect_to root_path, notice: "You are not logged in or authorized"
    end
  end
end
