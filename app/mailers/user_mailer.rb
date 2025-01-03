class UserMailer < ApplicationMailer
  default from: "no-reply@yourapp.com"

  def welcome_email(user, agency_name, password)
    @password = password
    @user = user
    @agency_name = agency_name
    @url  = new_user_session_url  # Ensure this points to the correct root path
    mail(to: @user.email, subject: "You are invited to manage your agency!")
  end
end
