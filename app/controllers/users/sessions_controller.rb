# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # def new
  #   respond_to do |format|
  #     format.html { super }
  #     format.turbo_stream { render partial: 'users/sessions/new', locals: { resource: resource } }
  #   end
  # end

  def create
    super do |resource|
      if resource.invalid?
        # If invalid, return a turbo stream with the form and the errors
        render turbo_stream: turbo_stream.replace(
          "session_form",
          partial: "users/sessions/form",
          locals: { resource: resource }
        )
        return
      else
        redirect_to after_sign_in_path_for(resource), status: :see_other and return
      end
    end
  end

  def destroy
    super
  end

  private

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [ :email, :password ])
  end
end
