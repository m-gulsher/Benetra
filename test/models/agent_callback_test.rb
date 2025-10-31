require "test_helper"

class AgentCallbackTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @agency = agencies(:one)
  end

  test "should log error when user update fails" do
    agent = Agent.new(
      name: "Test Agent",
      email: "test@example.com",
      user: @user,
      agency: @agency
    )

    # Stub user.update to return false
    @user.stub(:update, false) do
      @user.stub(:errors, OpenStruct.new(full_messages: ["Validation failed"])) do
        Rails.logger.expects(:error).with(regexp_matches(/Failed to update user/))

        agent.save!
      end
    end
  end

  test "should successfully update user authenticatable when valid" do
    agent = Agent.create!(
      name: "Test Agent",
      email: "test@example.com",
      user: @user,
      agency: @agency
    )

    @user.reload
    assert_equal "Agent", @user.authenticatable_type
    assert_equal agent.id, @user.authenticatable_id
  end

  test "should not attempt update if user is nil" do
    agent = Agent.new(
      name: "Test Agent",
      email: "test@example.com",
      agency: @agency
    )

    # Should not raise error when user is nil
    assert_nothing_raised do
      agent.save!
    end

    assert_nil agent.user
  end

  test "should handle update failure gracefully" do
    agent = Agent.new(
      name: "Test Agent",
      email: "test@example.com",
      user: @user,
      agency: @agency
    )

    # Stub user to fail update
    User.stub_any_instance(:update, false) do
      User.stub_any_instance(:errors, OpenStruct.new(full_messages: ["Some error"])) do
        Rails.logger.expects(:error).at_least_once

        # Agent should still be saved
        assert agent.save
      end
    end
  end

  test "should have consistent error handling with Employee model" do
    # Create agents and employees to test both callbacks behave similarly
    user1 = User.create!(name: "User 1", email: "user1@example.com", password: "password", role: "employee")
    user2 = User.create!(name: "User 2", email: "user2@example.com", password: "password", role: "agent")

    # Both should handle update failures similarly
    agent = Agent.new(name: "Test Agent", email: "agent@example.com", user: user2, agency: @agency)
    employee = Employee.new(name: "Test Employee", email: "emp@example.com", user: user1)

    # Stub both to fail and verify both log errors
    User.stub_any_instance(:update, false) do
      User.stub_any_instance(:errors, OpenStruct.new(full_messages: ["Test error"])) do
        Rails.logger.expects(:error).at_least(2) # Both Agent and Employee should log

        agent.save
        employee.save
      end
    end
  end
end
