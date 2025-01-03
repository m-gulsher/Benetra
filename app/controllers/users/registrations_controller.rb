class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :check_logged_in?

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:notice] = "Account created successfully. Please sign in to continue."
      redirect_to after_sign_up_path_for(@user), status: :see_other
    else
      render turbo_stream: turbo_stream.replace(
        "registration_form",
        partial: "users/registrations/form",
        locals: { user: @user }
      )
    end
  end

  def after_sign_up_path_for(resource)
    new_user_session_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end
end
