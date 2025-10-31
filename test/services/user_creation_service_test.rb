require "test_helper"

class UserCreationServiceTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
  end

  test "should create user and employee successfully" do
    service = UserCreationService.new(
      email: "newemployee@example.com",
      name: "New Employee",
      role: "employee",
      company_id: @company.id
    )

    assert_difference(["User.count", "Employee.count"], 1) do
      assert service.call
    end

    assert service.success?
    assert_equal "newemployee@example.com", service.user.email
    assert_equal "New Employee", service.user.name
    assert_equal "employee", service.user.role
    assert_equal "newemployee@example.com", service.authenticatable.email
    assert_equal @company.id, service.authenticatable.company_id
  end

  test "should create user and agent successfully" do
    agency = agencies(:one)
    service = UserCreationService.new(
      email: "newagent@example.com",
      name: "New Agent",
      role: "agent",
      agency_id: agency.id
    )

    assert_difference(["User.count", "Agent.count"], 1) do
      assert service.call
    end

    assert service.success?
    assert_equal "newagent@example.com", service.user.email
    assert_equal "agent", service.user.role
    assert_equal "newagent@example.com", service.authenticatable.email
    assert_equal agency.id, service.authenticatable.agency_id
  end

  test "should fail with blank email" do
    service = UserCreationService.new(
      email: "",
      name: "Test",
      role: "employee"
    )

    assert_no_difference(["User.count", "Employee.count"]) do
      assert_not service.call
    end

    assert_includes service.errors, "Email cannot be blank"
  end

  test "should fail with blank name" do
    service = UserCreationService.new(
      email: "test@example.com",
      name: "",
      role: "employee"
    )

    assert_no_difference(["User.count", "Employee.count"]) do
      assert_not service.call
    end

    assert_includes service.errors, "Name cannot be blank"
  end

  test "should fail with invalid role" do
    service = UserCreationService.new(
      email: "test@example.com",
      name: "Test",
      role: "invalid_role"
    )

    assert_no_difference(["User.count", "Employee.count"]) do
      assert_not service.call
    end

    assert_includes service.errors, "Invalid role: invalid_role"
  end

  test "should rollback user creation if employee creation fails" do
    # Create duplicate email to force validation error
    Employee.create!(name: "Existing", email: "duplicate@example.com", company: @company)

    service = UserCreationService.new(
      email: "duplicate@example.com",
      name: "Duplicate",
      role: "employee",
      company_id: @company.id
    )

    assert_no_difference(["User.count", "Employee.count"]) do
      assert_not service.call
    end
  end

  test "should rollback employee creation if user update fails" do
    service = UserCreationService.new(
      email: "testuser@example.com",
      name: "Test User",
      role: "employee",
      company_id: @company.id
    )

    User.stub_any_instance(:save, false) do
      assert_no_difference(["User.count", "Employee.count"]) do
        assert_not service.call
      end
    end
  end

  test "should generate random password if not provided" do
    service = UserCreationService.new(
      email: "test@example.com",
      name: "Test",
      role: "employee"
    )

    assert service.call
    assert service.user.password.present?
    assert service.user.password.length >= 16
  end

  test "should use provided password" do
    custom_password = "custompassword123"
    service = UserCreationService.new(
      email: "test@example.com",
      name: "Test",
      role: "employee",
      password: custom_password
    )

    assert service.call
    assert service.user.valid_password?(custom_password)
  end

  test "should link user to authenticatable after creation" do
    service = UserCreationService.new(
      email: "test@example.com",
      name: "Test",
      role: "employee",
      company_id: @company.id
    )

    assert service.call
    assert_equal "Employee", service.user.authenticatable_type
    assert_equal service.authenticatable.id, service.user.authenticatable_id
  end

  test "should handle transaction rollback on exception" do
    Employee.stub_any_instance(:save, proc { raise StandardError, "Unexpected error" }) do
      service = UserCreationService.new(
        email: "test@example.com",
        name: "Test",
        role: "employee",
        company_id: @company.id
      )

      assert_no_difference(["User.count", "Employee.count"]) do
        assert_not service.call
      end

      assert_includes service.errors.first, "Failed to create user"
    end
  end

  test "should create admin with admin role" do
    service = UserCreationService.new(
      email: "admin@example.com",
      name: "Admin User",
      role: "admin"
    )

    assert_difference(["User.count", "Admin.count"], 1) do
      assert service.call
    end

    assert_equal "admin", service.user.role
    assert_instance_of Admin, service.authenticatable
  end
end
