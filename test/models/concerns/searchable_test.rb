require "test_helper"

class SearchableTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
    @employee1 = employees(:one)
    @employee2 = employees(:two)
  end

  test "search_by returns all records when search term is blank" do
    results = Employee.search_by("")
    assert_equal Employee.count, results.count
  end

  test "search_by returns matching records for name search" do
    results = Employee.search_by("Test", :name)
    assert_includes results, @employee1
    assert_not_includes results, @employee2
  end

  test "search_by returns matching records for email search" do
    results = Employee.search_by("employee@example.com", :email)
    assert_includes results, @employee1
  end

  test "search_by is case insensitive" do
    results = Employee.search_by("test", :name)
    assert_includes results, @employee1
  end

  test "search_by supports partial matches" do
    results = Employee.search_by("Test", :name)
    assert_includes results, @employee1
  end

  test "search_by searches multiple fields" do
    results = Employee.search_by("employee", :name, :email)
    assert_includes results, @employee1
    assert_includes results, @employee2
  end

  test "filter_by returns all records when filter value is blank" do
    results = Employee.filter_by(:company_id, nil)
    assert_equal Employee.count, results.count
  end

  test "filter_by returns filtered records" do
    results = Employee.filter_by(:company_id, @company.id)
    assert_includes results, @employee1
    assert_includes results, @employee2
  end

  test "search_and_filter combines search and filter criteria" do
    results = Employee.search_and_filter("Test", { company_id: @company.id }, :name)
    assert_includes results, @employee1
  end

  test "paginated returns correct number of records" do
    Employee.create!(name: "Employee 3", email: "emp3@example.com", company: @company)
    Employee.create!(name: "Employee 4", email: "emp4@example.com", company: @company)

    results = Employee.paginated(page: 1, per_page: 2)
    assert_equal 2, results.count
  end

  test "paginated respects page parameter" do
    5.times do |i|
      Employee.create!(name: "Employee #{i}", email: "emp#{i}@example.com", company: @company)
    end

    page1 = Employee.paginated(page: 1, per_page: 2)
    page2 = Employee.paginated(page: 2, per_page: 2)

    assert_not_equal page1.pluck(:id), page2.pluck(:id)
  end

  test "total_pages calculates correctly" do
    5.times do |i|
      Employee.create!(name: "Employee #{i}", email: "emp#{i}@example.com", company: @company)
    end

    total = Employee.count
    pages = Employee.total_pages(per_page: 2)
    expected_pages = (total.to_f / 2).ceil

    assert_equal expected_pages, pages
  end

  test "paginated defaults to page 1 when invalid page provided" do
    results = Employee.paginated(page: -1, per_page: 10)
    first_page = Employee.paginated(page: 1, per_page: 10)

    assert_equal first_page.pluck(:id), results.pluck(:id)
  end

  test "paginated limits per_page to maximum of 100" do
    results = Employee.paginated(page: 1, per_page: 200)
    assert results.count <= 100
  end

  test "search_by with nil search term returns all" do
    results = Employee.search_by(nil, :name)
    assert_equal Employee.count, results.count
  end

  test "filter_by with empty string returns all" do
    results = Employee.filter_by(:company_id, "")
    assert_equal Employee.count, results.count
  end
end
