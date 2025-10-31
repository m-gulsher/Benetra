require "test_helper"

class CompaniesControllerSearchTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user

    @company1 = companies(:one)
    @company2 = companies(:two)
  end

  test "should display all companies without search parameters" do
    get companies_url
    assert_response :success
    assert_select "table tbody tr", count: Company.count
  end

  test "should filter companies by search term matching name" do
    get companies_url, params: { search: "Test Company" }
    assert_response :success
    assert_match(/Test Company/, response.body)
  end

  test "should filter companies by search term matching email" do
    get companies_url, params: { search: "company@example.com" }
    assert_response :success
    assert_match(/Test Company/, response.body)
  end

  test "should filter companies by search term matching poc_email" do
    get companies_url, params: { search: "poc@company.com" }
    assert_response :success
    assert_match(/Test Company/, response.body)
  end

  test "should paginate company results" do
    25.times do |i|
      Company.create!(
        name: "Company #{i}",
        email: "company#{i}@example.com",
        poc_email: "poc#{i}@example.com"
      )
    end

    get companies_url, params: { page: 1 }
    assert_response :success
    assert_select "table tbody tr", count: 20
  end

  test "should display pagination links for companies" do
    25.times do |i|
      Company.create!(
        name: "Company #{i}",
        email: "company#{i}@example.com",
        poc_email: "poc#{i}@example.com"
      )
    end

    get companies_url
    assert_response :success
    assert_match(/Previous|Next/, response.body)
  end

  test "search should be case insensitive for companies" do
    get companies_url, params: { search: "test" }
    assert_response :success
    assert_match(/Test Company/, response.body)
  end

  test "should handle empty search returns all companies" do
    get companies_url, params: { search: "" }
    assert_response :success
    assert_select "table tbody tr", count: Company.count
  end

  test "should display no results message when search returns empty" do
    get companies_url, params: { search: "NonExistentCompany" }
    assert_response :success
    assert_match(/No companies found/, response.body)
  end
end
