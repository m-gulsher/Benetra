require "test_helper"

class EmployeePolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:one)
    @admin.update(role: "admin")
    @agent = users(:two)
    @agent.update(role: "agent")
    @employee_user = users(:one).dup
    @employee_user.update(role: "employee")
    @company = companies(:one)
    @employee = employees(:one)
  end

  test "admin can index employees" do
    policy = EmployeePolicy.new(@admin, Employee)
    assert policy.index?
  end

  test "admin can show any employee" do
    policy = EmployeePolicy.new(@admin, @employee)
    assert policy.show?
  end

  test "admin can create employees" do
    policy = EmployeePolicy.new(@admin, Employee)
    assert policy.create?
  end

  test "admin can update any employee" do
    policy = EmployeePolicy.new(@admin, @employee)
    assert policy.update?
  end

  test "admin can destroy any employee" do
    policy = EmployeePolicy.new(@admin, @employee)
    assert policy.destroy?
  end

  test "agent can index employees" do
    policy = EmployeePolicy.new(@agent, Employee)
    assert policy.index?
  end

  test "agent can show employee from associated company" do
    policy = Policy.create!(name: "Test Policy", description: "Test", company: @company, agent: @agent.authenticatable)
    policy = EmployeePolicy.new(@agent, @employee)
    assert policy.show?
  end

  test "agent cannot create employees" do
    policy = EmployeePolicy.new(@agent, Employee)
    assert_not policy.create?
  end

  test "agent cannot update employees" do
    policy = EmployeePolicy.new(@agent, @employee)
    assert_not policy.update?
  end

  test "agent cannot destroy employees" do
    policy = EmployeePolicy.new(@agent, @employee)
    assert_not policy.destroy?
  end

  test "employee can index own employees" do
    policy = EmployeePolicy.new(@employee_user, Employee)
    assert policy.index?
  end

  test "employee can show own employee record" do
    employee = Employee.create!(name: "Test", email: "test@example.com", user: @employee_user)
    policy = EmployeePolicy.new(@employee_user, employee)
    assert policy.show?
  end

  test "employee cannot show other employee records" do
    policy = EmployeePolicy.new(@employee_user, @employee)
    assert_not policy.show?
  end

  test "employee cannot create employees" do
    policy = EmployeePolicy.new(@employee_user, Employee)
    assert_not policy.create?
  end

  test "employee can update own employee record" do
    employee = Employee.create!(name: "Test", email: "test@example.com", user: @employee_user)
    policy = EmployeePolicy.new(@employee_user, employee)
    assert policy.update?
  end

  test "employee cannot update other employee records" do
    policy = EmployeePolicy.new(@employee_user, @employee)
    assert_not policy.update?
  end

  test "employee cannot destroy employees" do
    policy = EmployeePolicy.new(@employee_user, @employee)
    assert_not policy.destroy?
  end

  test "scope resolves all employees for admin" do
    scope = EmployeePolicy::Scope.new(@admin, Employee).resolve
    assert_equal Employee.count, scope.count
  end

  test "scope resolves associated employees for agent" do
    agent = @agent.authenticatable
    policy = Policy.create!(name: "Test", description: "Test", company: @company, agent: agent)
    scope = EmployeePolicy::Scope.new(@agent, Employee).resolve
    assert_includes scope, @employee
  end

  test "scope resolves only own employee for employee user" do
    employee = Employee.create!(name: "Test", email: "test@example.com", user: @employee_user)
    scope = EmployeePolicy::Scope.new(@employee_user, Employee).resolve
    assert_equal 1, scope.count
    assert_includes scope, employee
  end
end
