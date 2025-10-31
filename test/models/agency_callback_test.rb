require "test_helper"

class AgencyCallbackTest < ActiveSupport::TestCase
  setup do
    @agency_data = {
      name: "Test Agency",
      email: "agency@example.com",
      poc_email: "jane.smith@example.com",
      phone: "123-456-7890"
    }
  end

  test "should create agent with poc_email not agency email" do
    agency = Agency.create!(@agency_data)

    agent = Agent.find_by(agency_id: agency.id)
    assert_not_nil agent
    assert_equal "jane.smith@example.com", agent.email
    assert_not_equal "agency@example.com", agent.email
  end

  test "should create user with poc_email" do
    agency = Agency.create!(@agency_data)

    user = User.find_by(email: "jane.smith@example.com")
    assert_not_nil user
    assert_equal "jane.smith@example.com", user.email
    assert_equal "agent", user.role
  end

  test "should link user to agent correctly" do
    agency = Agency.create!(@agency_data)

    agent = Agent.find_by(agency_id: agency.id)
    user = User.find_by(email: "jane.smith@example.com")

    assert_equal agent.user, user
    assert_equal user.authenticatable, agent
  end

  test "should send reminder email if user already exists" do
    existing_user = User.create!(
      name: "Jane Smith",
      email: "jane.smith@example.com",
      password: "password",
      role: "agent"
    )

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob, args: ["UserMailer", "reminder_email", "deliver_now", { args: [existing_user] }]) do
      Agency.create!(@agency_data)
    end
  end

  test "should not create agent if user already exists" do
    existing_user = User.create!(
      name: "Jane Smith",
      email: "jane.smith@example.com",
      password: "password",
      role: "agent"
    )

    assert_no_difference("Agent.count") do
      Agency.create!(@agency_data)
    end
  end

  test "should rollback user creation if agent creation fails" do
    # Force agent validation error by creating duplicate email
    Agent.create!(
      name: "Existing",
      email: "jane.smith@example.com",
      agency: agencies(:one)
    )

    assert_no_difference(["User.count", "Agent.count"]) do
      agency = Agency.new(@agency_data)
      agency.save
      assert agency.persisted?
    end
  end

  test "should set agent agency_id correctly" do
    agency = Agency.create!(@agency_data)

    agent = Agent.find_by(agency_id: agency.id)
    assert_not_nil agent
    assert_equal agency.id, agent.agency_id
  end

  test "should capitalize name from email" do
    agency = Agency.create!(@agency_data)

    user = User.find_by(email: "jane.smith@example.com")
    assert_equal "Jane.smith", user.name
  end

  test "should send welcome email after successful creation" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob, args: ["UserMailer", "welcome_email", "deliver_now"]) do
      Agency.create!(@agency_data)
    end
  end
end
