class ApplicationController < ActionController::Base
  include Authorizable

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :set_pundit_user

  def after_sign_in_path_for(resource)
    return agencies_path if resource.role == "admin"
    return policies_path if resource.role == "agent"
    return employees_path if resource.role == "employee"

    root_path
  end

  def pundit_user
    current_user
  end

  private

  def set_pundit_user
    @pundit_user = current_user
  end
end
