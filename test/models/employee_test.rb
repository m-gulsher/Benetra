require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
  end

  test "should be valid with valid attributes" do
    employee = Employee.new(name: "Test Employee", email: "test@example.com", company: @company)
    assert employee.valid?
  end

  test "should require name" do
    employee = Employee.new(email: "test@example.com", company: @company)
    assert_not employee.valid?
    assert_includes employee.errors[:name], "can't be blank"
  end

  test "should require email" do
    employee = Employee.new(name: "Test Employee", company: @company)
    assert_not employee.valid?
    assert_includes employee.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    Employee.create!(name: "First", email: "test@example.com", company: @company)
    employee = Employee.new(name: "Second", email: "test@example.com", company: @company)
    assert_not employee.valid?
    assert_includes employee.errors[:email], "has already been taken"
  end

  test "should validate email format" do
    employee = Employee.new(name: "Test", email: "invalid-email", company: @company)
    assert_not employee.valid?
    assert_includes employee.errors[:email], "must be a valid email address"
  end

  test "should allow company to be optional" do
    employee = Employee.new(name: "Test", email: "test@example.com")
    assert employee.valid?
  end

  test "should belong to company when assigned" do
    employee = Employee.create!(name: "Test", email: "test@example.com", company: @company)
    assert_equal @company, employee.company
  end

  test "should search by name" do
    employee = Employee.create!(name: "John Doe", email: "john@example.com", company: @company)
    results = Employee.search_by("John", :name)
    assert_includes results, employee
  end

  test "should search by email" do
    employee = Employee.create!(name: "Jane", email: "jane@example.com", company: @company)
    results = Employee.search_by("jane@example.com", :email)
    assert_includes results, employee
  end

  test "should filter by company" do
    employee1 = Employee.create!(name: "Employee 1", email: "emp1@example.com", company: @company)
    company2 = companies(:two)
    employee2 = Employee.create!(name: "Employee 2", email: "emp2@example.com", company: company2)

    results = Employee.filter_by(:company_id, @company.id)
    assert_includes results, employee1
    assert_not_includes results, employee2
  end
end
