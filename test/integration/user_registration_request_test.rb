# # test/integration/user_registration_request_test.rb
# require 'test_helper'

# class UserRegistrationRequestTest < ActionDispatch::IntegrationTest
#   test "user should be able to register with valid parameters" do
#     user_params = { name: 'Test User', email: 'test@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin' }
    
#     post user_registration_url, params: { user: user_params }
    
#     assert_response :see_other
#     assert_redirected_to new_user_session_path
#     follow_redirect!
#     assert_match 'Account created successfully. Please sign in to continue.', flash[:notice]
#   end
# end
