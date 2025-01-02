# # test/integration/user_session_request_test.rb
# require 'test_helper'

# class UserSessionRequestTest < ActionDispatch::IntegrationTest
#   def setup
#     @user = users(:one)
#   end
  
#   test "should log in with valid credentials" do
#     post user_session_url, params: { user: { email: @user.email, password: 'password' } }
    
#     assert_response :see_other
#     assert_redirected_to root_path
#   end

#   test "should return form with errors for invalid credentials" do
#     post user_session_url, params: { user: { email: @user.email, password: 'invalidpassword' } }
    
#     assert_response :success
#     assert_match 'Invalid', response.body
#   end
# end
