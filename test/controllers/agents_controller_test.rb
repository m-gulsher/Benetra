require "test_helper"

class AgentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @agent = agents(:one)
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get agents_url
    assert_response :success
  end

  test "should get new" do
    get new_agent_url
    assert_response :success
  end

  test "should show agent" do
    get agent_url(@agent)
    assert_response :success
  end

  test "should get edit" do
    get edit_agent_url(@agent)
    assert_response :success
  end

  test "should destroy agent" do
    assert_difference("Agent.count", -1) do
      delete agent_url(@agent)
    end

    assert_redirected_to agents_url
  end
end
