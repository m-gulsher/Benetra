require "application_system_test_case"

class AgenciesTest < ApplicationSystemTestCase
  setup do
    @agency = agencies(:one)
  end

  test "visiting the index" do
    visit agencies_url
    assert_selector "h1", text: "Agencies"
  end

  test "should create agency" do
    visit agencies_url
    click_on "New agency"

    click_on "Create Agency"

    assert_text "Agency was successfully created"
    click_on "Back"
  end

  test "should update Agency" do
    visit agency_url(@agency)
    click_on "Edit this agency", match: :first

    click_on "Update Agency"

    assert_text "Agency was successfully updated"
    click_on "Back"
  end

  test "should destroy Agency" do
    visit agency_url(@agency)
    click_on "Destroy this agency", match: :first

    assert_text "Agency was successfully destroyed"
  end
end
