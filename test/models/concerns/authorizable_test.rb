require "test_helper"

class AuthorizableTest < ActiveSupport::TestCase
  # Create a test controller class to test Authorizable concern
  class TestController < ActionController::Base
    include Authorizable
  end

  setup do
    @controller = TestController.new
    @controller.define_singleton_method(:user_signed_in?) { !!@current_user }
    @controller.define_singleton_method(:current_user) { @current_user }
    @controller.define_singleton_method(:redirect_to) { |*args| }
    @admin_user = User.create!(name: "Admin", email: "admin@test.com", password: "password", role: "admin")
    @agent_user = User.create!(name: "Agent", email: "agent@test.com", password: "password", role: "agent")
    @employee_user = User.create!(name: "Employee", email: "employee@test.com", password: "password", role: "employee")
    @agent = Agent.create!(name: "Agent", email: "agent@test.com", user: @agent_user)
    @employee = Employee.create!(name: "Employee", email: "employee@test.com", user: @employee_user)
    @company = Company.create!(name: "Company", email: "company@test.com", poc_email: "poc@test.com")
    @policy = Policy.create!(name: "Policy", description: "Test", company: @company, agent: @agent)
  end

  test "admin? returns true for admin user" do
    @controller.instance_variable_set(:@current_user, @admin_user)
    assert @controller.admin?
  end

  test "admin? returns false for agent user" do
    @controller.instance_variable_set(:@current_user, @agent_user)
    assert_not @controller.admin?
  end

  test "agent? returns true for agent user" do
    @controller.instance_variable_set(:@current_user, @agent_user)
    assert @controller.agent?
  end

  test "employee? returns true for employee user" do
    @controller.instance_variable_set(:@current_user, @employee_user)
    assert @controller.employee?
  end

  test "can? returns true for admin manage action" do
    @controller.instance_variable_set(:@current_user, @admin_user)
    assert @controller.can?(:manage, Employee)
  end

  test "can? returns false for agent create employee" do
    @controller.instance_variable_set(:@current_user, @agent_user)
    assert_not @controller.can?(:create, Employee)
  end

  test "can? returns true for agent view own policy" do
    @controller.instance_variable_set(:@current_user, @agent_user)
    assert @controller.can?(:show, @policy)
  end

  test "can? returns false for agent view other policy" do
    other_policy = Policy.create!(name: "Other", description: "Test", company: @company, agent: agents(:one))
    @controller.instance_variable_set(:@current_user, @agent_user)
    assert_not @controller.can?(:show, other_policy)
  end

  test "can? returns true for employee view own employee" do
    @controller.instance_variable_set(:@current_user, @employee_user)
    assert @controller.can?(:show, @employee)
  end

  test "can? returns false for employee view other employee" do
    other_employee = employees(:one)
    @controller.instance_variable_set(:@current_user, @employee_user)
    assert_not @controller.can?(:show, other_employee)
  end

  test "owns_resource? returns true for admin" do
    @controller.instance_variable_set(:@current_user, @admin_user)
    assert @controller.owns_resource?(@policy)
  end

  test "owns_resource? returns true for agent own policy" do
    @controller.instance_variable_set(:@current_user, @agent_user)
    assert @controller.owns_resource?(@policy)
  end

  test "owns_resource? returns false for agent other policy" do
    other_policy = Policy.create!(name: "Other", description: "Test", company: @company, agent: agents(:one))
    @controller.instance_variable_set(:@current_user, @agent_user)
    assert_not @controller.owns_resource?(other_policy)
  end

  test "owns_resource? returns true for employee own employee" do
    @controller.instance_variable_set(:@current_user, @employee_user)
    assert @controller.owns_resource?(@employee)
  end

  test "owns_resource? returns false for employee other employee" do
    other_employee = employees(:one)
    @controller.instance_variable_set(:@current_user, @employee_user)
    assert_not @controller.owns_resource?(other_employee)
  end
end
