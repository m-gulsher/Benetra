require "test_helper"

class AuthorizationTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @admin.update(role: "admin")
    @agent_user = User.create!(name: "Agent User", email: "agent@example.com", password: "password", role: "agent")
    @agent = Agent.create!(name: "Test Agent", email: "agent@example.com", user: @agent_user)
    @employee_user = User.create!(name: "Employee User", email: "employee@example.com", password: "password", role: "employee")
    @employee = Employee.create!(name: "Test Employee", email: "employee@example.com", company: companies(:one), user: @employee_user)
    @company = companies(:one)
    @policy = Policy.create!(name: "Test Policy", description: "Test", company: @company, agent: @agent)
  end

  test "admin can access all employees" do
    sign_in @admin
    get employees_url
    assert_response :success
  end

  test "admin can create employees" do
    sign_in @admin
    get new_employee_url
    assert_response :success
  end

  test "agent can access employees from associated companies" do
    sign_in @agent_user
    get employees_url
    assert_response :success
  end

  test "agent cannot create employees" do
    sign_in @agent_user
    get new_employee_url
    assert_redirected_to root_path
    assert_match(/not authorized/, flash[:alert])
  end

  test "employee can access own employee record" do
    sign_in @employee_user
    get employee_url(@employee)
    assert_response :success
  end

  test "employee cannot access other employee records" do
    other_employee = employees(:one)
    sign_in @employee_user
    get employee_url(other_employee)
    assert_redirected_to root_path
  end

  test "employee can update own employee record" do
    sign_in @employee_user
    get edit_employee_url(@employee)
    assert_response :success
  end

  test "employee cannot update other employee records" do
    other_employee = employees(:one)
    sign_in @employee_user
    get edit_employee_url(other_employee)
    assert_redirected_to root_path
  end

  test "admin can access all policies" do
    sign_in @admin
    get policies_url
    assert_response :success
  end

  test "admin can create policies" do
    sign_in @admin
    get new_policy_url
    assert_response :success
  end

  test "agent can access own policies" do
    sign_in @agent_user
    get policies_url
    assert_response :success
    assert_includes assigns(:policies), @policy
  end

  test "agent can create policies" do
    sign_in @agent_user
    get new_policy_url
    assert_response :success
  end

  test "agent can update own policy" do
    sign_in @agent_user
    get edit_policy_url(@policy)
    assert_response :success
  end

  test "employee can view policies from own company" do
    sign_in @employee_user
    get policies_url
    assert_response :success
  end

  test "employee cannot create policies" do
    sign_in @employee_user
    get new_policy_url
    assert_redirected_to root_path
  end

  test "employee cannot update policies" do
    sign_in @employee_user
    get edit_policy_url(@policy)
    assert_redirected_to root_path
  end

  test "admin can access all companies" do
    sign_in @admin
    get companies_url
    assert_response :success
  end

  test "admin can create companies" do
    sign_in @admin
    get new_company_url
    assert_response :success
  end

  test "agent can view associated companies" do
    sign_in @agent_user
    get companies_url
    assert_response :success
  end

  test "agent cannot create companies" do
    sign_in @agent_user
    get new_company_url
    assert_redirected_to root_path
  end

  test "employee can view own company" do
    sign_in @employee_user
    get company_url(@company)
    assert_response :success
  end

  test "employee cannot access other companies" do
    other_company = companies(:two)
    sign_in @employee_user
    get company_url(other_company)
    assert_redirected_to root_path
  end

  test "employee cannot create companies" do
    sign_in @employee_user
    get new_company_url
    assert_redirected_to root_path
  end

  test "admin can access agents" do
    sign_in @admin
    get agents_url
    assert_response :success
  end

  test "agent can view own agent profile" do
    sign_in @agent_user
    get agent_url(@agent)
    assert_response :success
  end

  test "agent cannot view other agent profiles" do
    other_agent = agents(:one)
    sign_in @agent_user
    get agent_url(other_agent)
    assert_redirected_to root_path
  end

  test "employee cannot access agents" do
    sign_in @employee_user
    get agents_url
    assert_redirected_to root_path
  end

  test "admin can delete any employee" do
    sign_in @admin
    assert_difference("Employee.count", -1) do
      delete employee_url(@employee)
    end
  end

  test "agent cannot delete employees" do
    sign_in @agent_user
    assert_no_difference("Employee.count") do
      delete employee_url(@employee)
    end
    assert_redirected_to root_path
  end

  test "employee cannot delete employees" do
    sign_in @employee_user
    assert_no_difference("Employee.count") do
      delete employee_url(@employee)
    end
    assert_redirected_to root_path
  end
end
