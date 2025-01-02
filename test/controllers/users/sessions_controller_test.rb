# # test/controllers/users/sessions_controller_test.rb
# require 'test_helper'

# class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
#   def setup
#     @user = users(:one)
#   end

#   test "should create session and redirect to after_sign_in_path" do
#     post user_session_url, params: { user: { email: @user.email, password: 'password' } }

#     assert_response :see_other
#     assert_redirected_to root_path
#   end

#   test "should render form with errors if credentials are invalid" do
#     post user_session_url, params: { user: { email: @user.email, password: 'wrongpassword' } }

#     assert_response :success
#     assert_match 'Invalid', response.body
#     assert_match 'email', response.body
#   end

#   test "should destroy session and redirect to login" do
#     sign_in @user
#     delete destroy_user_session_url
#     assert_redirected_to new_user_session_path
#   end
# end
