require "test_helper"

class PoliciesControllerSearchTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @company = companies(:one)
    @company2 = companies(:two)
    @agency = agencies(:one)
    @agent = agents(:one)

    sign_in @user

    @policy1 = Policy.create!(
      name: "Health Insurance Policy",
      description: "Comprehensive health coverage",
      company: @company,
      agent: @agent
    )

    @policy2 = Policy.create!(
      name: "Dental Insurance",
      description: "Dental coverage plan",
      company: @company2,
      agent: @agent
    )

    @policy3 = Policy.create!(
      name: "Life Insurance",
      description: "Life coverage policy",
      company: @company
    )
  end

  test "should display all policies without search parameters" do
    get policies_url
    assert_response :success
    assert_select "table tbody tr", count: Policy.count
  end

  test "should filter policies by search term matching name" do
    get policies_url, params: { search: "Health" }
    assert_response :success
    assert_match(/Health Insurance Policy/, response.body)
  end

  test "should filter policies by search term matching description" do
    get policies_url, params: { search: "Comprehensive" }
    assert_response :success
    assert_match(/Health Insurance Policy/, response.body)
  end

  test "should filter policies by company" do
    get policies_url, params: { company_id: @company.id }
    assert_response :success
    assert_match(/Health Insurance Policy/, response.body)
    assert_match(/Life Insurance/, response.body)
    assert_no_match(/Dental Insurance/, response.body)
  end

  test "should filter policies by agent" do
    get policies_url, params: { agent_id: @agent.id }
    assert_response :success
    assert_match(/Health Insurance Policy/, response.body)
    assert_match(/Dental Insurance/, response.body)
    assert_no_match(/Life Insurance/, response.body)
  end

  test "should combine search, company, and agent filters" do
    get policies_url, params: { search: "Insurance", company_id: @company.id, agent_id: @agent.id }
    assert_response :success
    assert_match(/Health Insurance Policy/, response.body)
    assert_no_match(/Dental Insurance/, response.body)
    assert_no_match(/Life Insurance/, response.body)
  end

  test "should paginate policy results" do
    25.times do |i|
      Policy.create!(name: "Policy #{i}", description: "Description #{i}", company: @company)
    end

    get policies_url, params: { page: 1 }
    assert_response :success
    assert_select "table tbody tr", count: 20
  end

  test "should display pagination info for policies" do
    get policies_url
    assert_response :success
    assert_match(/Showing/, response.body)
  end

  test "search should be case insensitive for policies" do
    get policies_url, params: { search: "health" }
    assert_response :success
    assert_match(/Health Insurance Policy/, response.body)
  end

  test "should handle empty search returns all policies" do
    get policies_url, params: { search: "" }
    assert_response :success
    assert_select "table tbody tr", count: Policy.count
  end
end
