require "test_helper"

class PolicyPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:one)
    @admin.update(role: "admin")
    @agent = users(:two)
    @agent.update(role: "agent")
    @employee_user = users(:one).dup
    @employee_user.update(role: "employee")
    @company = companies(:one)
    @policy = policies(:one)
  end

  test "admin can index policies" do
    policy = PolicyPolicy.new(@admin, Policy)
    assert policy.index?
  end

  test "admin can show any policy" do
    policy = PolicyPolicy.new(@admin, @policy)
    assert policy.show?
  end

  test "admin can create policies" do
    policy = PolicyPolicy.new(@admin, Policy)
    assert policy.create?
  end

  test "admin can update any policy" do
    policy = PolicyPolicy.new(@admin, @policy)
    assert policy.update?
  end

  test "admin can destroy any policy" do
    policy = PolicyPolicy.new(@admin, @policy)
    assert policy.destroy?
  end

  test "agent can index policies" do
    policy = PolicyPolicy.new(@agent, Policy)
    assert policy.index?
  end

  test "agent can show own policy" do
    agent_policy = Policy.create!(name: "Agent Policy", description: "Test", company: @company, agent: @agent.authenticatable)
    policy = PolicyPolicy.new(@agent, agent_policy)
    assert policy.show?
  end

  test "agent cannot show other agent policy" do
    policy = PolicyPolicy.new(@agent, @policy)
    assert_not policy.show?
  end

  test "agent can create policies" do
    policy = PolicyPolicy.new(@agent, Policy)
    assert policy.create?
  end

  test "agent can update own policy" do
    agent_policy = Policy.create!(name: "Agent Policy", description: "Test", company: @company, agent: @agent.authenticatable)
    policy = PolicyPolicy.new(@agent, agent_policy)
    assert policy.update?
  end

  test "agent cannot update other agent policy" do
    policy = PolicyPolicy.new(@agent, @policy)
    assert_not policy.update?
  end

  test "agent can destroy own policy" do
    agent_policy = Policy.create!(name: "Agent Policy", description: "Test", company: @company, agent: @agent.authenticatable)
    policy = PolicyPolicy.new(@agent, agent_policy)
    assert policy.destroy?
  end

  test "agent cannot destroy other agent policy" do
    policy = PolicyPolicy.new(@agent, @policy)
    assert_not policy.destroy?
  end

  test "employee can index policies" do
    policy = PolicyPolicy.new(@employee_user, Policy)
    assert policy.index?
  end

  test "employee can show policy from own company" do
    employee = Employee.create!(name: "Test", email: "test@example.com", company: @company, user: @employee_user)
    policy = PolicyPolicy.new(@employee_user, @policy)
    assert policy.show?
  end

  test "employee cannot create policies" do
    policy = PolicyPolicy.new(@employee_user, Policy)
    assert_not policy.create?
  end

  test "employee cannot update policies" do
    policy = PolicyPolicy.new(@employee_user, @policy)
    assert_not policy.update?
  end

  test "employee cannot destroy policies" do
    policy = PolicyPolicy.new(@employee_user, @policy)
    assert_not policy.destroy?
  end

  test "scope resolves all policies for admin" do
    scope = PolicyPolicy::Scope.new(@admin, Policy).resolve
    assert_equal Policy.count, scope.count
  end

  test "scope resolves only own policies for agent" do
    agent_policy = Policy.create!(name: "Agent Policy", description: "Test", company: @company, agent: @agent.authenticatable)
    scope = PolicyPolicy::Scope.new(@agent, Policy).resolve
    assert_equal 1, scope.count
    assert_includes scope, agent_policy
  end

  test "scope resolves company policies for employee" do
    employee = Employee.create!(name: "Test", email: "test@example.com", company: @company, user: @employee_user)
    scope = PolicyPolicy::Scope.new(@employee_user, Policy).resolve
    assert_includes scope, @policy
  end
end
