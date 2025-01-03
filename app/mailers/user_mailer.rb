class UserMailer < ApplicationMailer
  default from: "no-reply@yourapp.com"

  def welcome_email(user, agency_name, password)
    @password = password
    @user = user
    @agency_name = agency_name
    @url  = new_user_session_url
    mail(to: @user.email, subject: "You are invited to manage your agency!")
  end

  def reminder_email(user)
    @user = user
    @url  = new_user_session_url
    mail(to: @user.email, subject: "Reminder: You can manage your agency on our platform!")
  end
end
