require "test_helper"

class EmployeesControllerSearchTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @company = companies(:one)
    @company2 = companies(:two)

    sign_in @user

    @employee1 = Employee.create!(
      name: "John Doe",
      email: "john@example.com",
      phone: "123-456-7890",
      company: @company
    )

    @employee2 = Employee.create!(
      name: "Jane Smith",
      email: "jane@example.com",
      phone: "098-765-4321",
      company: @company2
    )

    @employee3 = Employee.create!(
      name: "Bob Johnson",
      email: "bob@example.com",
      company: @company
    )
  end

  test "should display all employees without search parameters" do
    get employees_url
    assert_response :success
    assert_select "table tbody tr", count: Employee.count
  end

  test "should filter employees by search term matching name" do
    get employees_url, params: { search: "John" }
    assert_response :success
    assert_select "table tbody tr", count: 1
    assert_match(/John Doe/, response.body)
  end

  test "should filter employees by search term matching email" do
    get employees_url, params: { search: "jane@example.com" }
    assert_response :success
    assert_select "table tbody tr", count: 1
    assert_match(/Jane Smith/, response.body)
  end

  test "should filter employees by search term matching phone" do
    get employees_url, params: { search: "123-456" }
    assert_response :success
    assert_select "table tbody tr", count: 1
    assert_match(/John Doe/, response.body)
  end

  test "should filter employees by company" do
    get employees_url, params: { company_id: @company.id }
    assert_response :success
    # Should include employees from company 1, excluding company 2
    assert_match(/John Doe/, response.body)
    assert_match(/Bob Johnson/, response.body)
    assert_no_match(/Jane Smith/, response.body)
  end

  test "should combine search and company filter" do
    get employees_url, params: { search: "John", company_id: @company.id }
    assert_response :success
    assert_select "table tbody tr", count: 1
    assert_match(/John Doe/, response.body)
  end

  test "should paginate results with default per page" do
    25.times do |i|
      Employee.create!(name: "Employee #{i}", email: "emp#{i}@example.com", company: @company)
    end

    get employees_url, params: { page: 1 }
    assert_response :success
    assert_select "table tbody tr", count: 20
  end

  test "should navigate to second page of results" do
    25.times do |i|
      Employee.create!(name: "Employee #{i}", email: "emp#{i}@example.com", company: @company)
    end

    get employees_url, params: { page: 2 }
    assert_response :success
    assert_select "table tbody tr", count: 7 # 25 total - 20 on page 1 = 5 remaining + 2 from fixtures = 7
  end

  test "should display pagination links when multiple pages exist" do
    25.times do |i|
      Employee.create!(name: "Employee #{i}", email: "emp#{i}@example.com", company: @company)
    end

    get employees_url
    assert_response :success
    assert_match(/Previous|Next/, response.body)
  end

  test "should preserve search parameters in pagination links" do
    25.times do |i|
      Employee.create!(name: "Employee #{i}", email: "emp#{i}@example.com", company: @company)
    end

    get employees_url, params: { search: "Employee", page: 2 }
    assert_response :success
    assert_match(/search=Employee/, response.body)
  end

  test "should display no results message when search returns empty" do
    get employees_url, params: { search: "NonExistentName" }
    assert_response :success
    assert_match(/No employees found/, response.body)
  end

  test "should display pagination info with correct counts" do
    25.times do |i|
      Employee.create!(name: "Employee #{i}", email: "emp#{i}@example.com", company: @company)
    end

    get employees_url
    assert_response :success
    total = Employee.count
    assert_match(/#{total}/, response.body)
  end

  test "search should be case insensitive" do
    get employees_url, params: { search: "john" }
    assert_response :success
    assert_match(/John Doe/, response.body)
  end

  test "should handle empty search parameter" do
    get employees_url, params: { search: "" }
    assert_response :success
    assert_select "table tbody tr", count: Employee.count
  end

  test "should clear search when clear button is clicked" do
    get employees_url, params: { search: "John" }
    assert_response :success

    get employees_url
    assert_response :success
    assert_select "table tbody tr", count: Employee.count
  end
end
