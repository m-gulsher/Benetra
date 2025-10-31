require "test_helper"

class EmployeeCallbackTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "should log error when user update fails" do
    employee = Employee.new(
      name: "Test Employee",
      email: "test@example.com",
      user: @user
    )

    # Stub user.update to return false
    @user.stub(:update, false) do
      @user.stub(:errors, OpenStruct.new(full_messages: ["Validation failed"])) do
        Rails.logger.expects(:error).with(regexp_matches(/Failed to update user/))

        employee.save!
      end
    end
  end

  test "should successfully update user authenticatable when valid" do
    employee = Employee.create!(
      name: "Test Employee",
      email: "test@example.com",
      user: @user
    )

    @user.reload
    assert_equal "Employee", @user.authenticatable_type
    assert_equal employee.id, @user.authenticatable_id
  end

  test "should not attempt update if user is nil" do
    employee = Employee.new(
      name: "Test Employee",
      email: "test@example.com"
    )

    # Should not raise error when user is nil
    assert_nothing_raised do
      employee.save!
    end

    assert_nil employee.user
  end

  test "should handle update failure gracefully" do
    employee = Employee.new(
      name: "Test Employee",
      email: "test@example.com",
      user: @user
    )

    # Stub user to fail update
    User.stub_any_instance(:update, false) do
      User.stub_any_instance(:errors, OpenStruct.new(full_messages: ["Some error"])) do
        Rails.logger.expects(:error).at_least_once

        # Employee should still be saved
        assert employee.save
      end
    end
  end
end
