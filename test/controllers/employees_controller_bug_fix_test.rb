require "test_helper"

class EmployeesControllerBugFixTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @company = companies(:one)
  end

  test "index should set @pending_invitations_count" do
    # Create employees without users
    Employee.create!(name: "Pending 1", email: "pending1@example.com")
    Employee.create!(name: "Pending 2", email: "pending2@example.com")

    # Create employee with user
    user = User.create!(name: "User", email: "user@example.com", password: "password", role: "employee")
    Employee.create!(name: "With User", email: "withuser@example.com", user: user)

    get employees_path

    assert_response :success
    # Verify the variable is set (it's used in the view)
    assert_select "span.text-lg.font-semibold", text: "2"
  end

  test "index should handle zero pending invitations" do
    Employee.destroy_all
    get employees_path

    assert_response :success
    assert_select "span.text-lg.font-semibold", text: "0"
  end

  test "create should display validation errors" do
    # Try to create employee with duplicate email
    existing_employee = employees(:one)

    post employees_path, params: {
      employee: {
        name: "Test",
        email: existing_employee.email,
        phone: "123-456-7890"
      }
    }

    assert_response :unprocessable_entity
    assert_match /error/i, response.body
    assert_match /already been taken/i, response.body
  end

  test "create should display field-specific errors" do
    post employees_path, params: {
      employee: {
        name: "",
        email: "",
        phone: "123-456-7890"
      }
    }

    assert_response :unprocessable_entity
    assert_match /name/i, response.body
    assert_match /email/i, response.body
  end

  test "update should display validation errors" do
    employee = employees(:one)
    duplicate_employee = Employee.create!(name: "Duplicate", email: "duplicate@example.com")

    patch employee_path(employee), params: {
      employee: {
        name: employee.name,
        email: duplicate_employee.email,
        phone: employee.phone
      }
    }

    assert_response :unprocessable_entity
    assert_match /error/i, response.body
    assert_match /already been taken/i, response.body
  end
end
