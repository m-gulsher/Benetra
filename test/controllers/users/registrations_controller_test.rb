# test/controllers/users/registrations_controller_test.rb
require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should create user and redirect to sign_in" do
    user_params = { name: "Test User", email: "test@example.com", password: "password123", password_confirmation: "password123", role: "admin" }

    post user_registration_url, params: { user: user_params }

    assert_response :see_other
    assert_redirected_to new_user_session_path
    follow_redirect!
    assert_match "Account created successfully. Please sign in to continue.", flash[:notice]
  end

  test "should render form when user creation fails" do
    user_params = { name: "Test User", email: "test@example.com", password: "password123", password_confirmation: "differentpassword", role: "admin" }

    post user_registration_url, params: { user: user_params }

    assert_response :success
    assert_match "email", response.body
    assert_match "password_confirmation", response.body
  end
end
