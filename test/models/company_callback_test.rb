require "test_helper"

class CompanyCallbackTest < ActiveSupport::TestCase
  setup do
    @company_data = {
      name: "Test Company",
      email: "company@example.com",
      poc_email: "john.doe@example.com",
      phone: "123-456-7890"
    }
  end

  test "should create employee with poc_email not company email" do
    company = Company.create!(@company_data)

    employee = Employee.find_by(company_id: company.id)
    assert_not_nil employee
    assert_equal "john.doe@example.com", employee.email
    assert_not_equal "company@example.com", employee.email
  end

  test "should create user with poc_email" do
    company = Company.create!(@company_data)

    user = User.find_by(email: "john.doe@example.com")
    assert_not_nil user
    assert_equal "john.doe@example.com", user.email
    assert_equal "employee", user.role
  end

  test "should link user to employee correctly" do
    company = Company.create!(@company_data)

    employee = Employee.find_by(company_id: company.id)
    user = User.find_by(email: "john.doe@example.com")

    assert_equal employee.user, user
    assert_equal user.authenticatable, employee
  end

  test "should send reminder email if user already exists" do
    existing_user = User.create!(
      name: "John Doe",
      email: "john.doe@example.com",
      password: "password",
      role: "employee"
    )

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob, args: ["UserMailer", "reminder_email", "deliver_now", { args: [existing_user] }]) do
      Company.create!(@company_data)
    end
  end

  test "should not create employee if user already exists" do
    existing_user = User.create!(
      name: "John Doe",
      email: "john.doe@example.com",
      password: "password",
      role: "employee"
    )

    assert_no_difference("Employee.count") do
      Company.create!(@company_data)
    end
  end

  test "should rollback user creation if employee creation fails" do
    # Force employee validation error by creating duplicate email
    Employee.create!(
      name: "Existing",
      email: "john.doe@example.com",
      company: companies(:one)
    )

    assert_no_difference(["User.count", "Employee.count"]) do
      company = Company.new(@company_data)
      company.save
      # Note: Company saves but employee/user creation should rollback
      assert company.persisted?
    end
  end

  test "should handle transaction failure gracefully" do
    User.stub_any_instance(:save, false) do
      company = Company.new(@company_data)

      assert_nothing_raised do
        company.save
      end
    end
  end

  test "should set employee company_id correctly" do
    company = Company.create!(@company_data)

    employee = Employee.find_by(company_id: company.id)
    assert_not_nil employee
    assert_equal company.id, employee.company_id
  end

  test "should capitalize name from email" do
    company = Company.create!(@company_data)

    user = User.find_by(email: "john.doe@example.com")
    assert_equal "John.doe", user.name
  end

  test "should send welcome email after successful creation" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob, args: ["UserMailer", "welcome_email", "deliver_now"]) do
      Company.create!(@company_data)
    end
  end
end
