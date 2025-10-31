require "test_helper"

class EmployeeImportServiceErrorHandlingTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
    @temp_file = Tempfile.new(["test_employees", ".csv"])
  end

  teardown do
    @temp_file&.close
    @temp_file&.unlink
    Rails.cache.clear
  end

  test "should handle file not found error" do
    service = EmployeeImportService.new("/nonexistent/file.csv")

    assert_not service.perform
    assert_includes service.errors.first, "File not found"
  end

  test "should handle empty CSV file" do
    CSV.open(@temp_file.path, "w", write_headers: true, headers: ["name", "email"]) do |csv|
      # No rows
    end

    service = EmployeeImportService.new(@temp_file.path)

    assert_not service.perform
    assert_includes service.errors.first, "CSV file is empty"
  end

  test "should handle malformed CSV file" do
    @temp_file.write("invalid,csv\ncontent,with\"unclosed quote")
    @temp_file.close

    service = EmployeeImportService.new(@temp_file.path)

    assert_not service.perform
    assert service.errors.any? { |e| e.include?("Invalid CSV format") || e.include?("CSV") }
  end

  test "should handle CSV read errors gracefully" do
    # Create a file that exists but can't be read as CSV
    @temp_file.write("invalid csv content with no proper format")
    @temp_file.close

    service = EmployeeImportService.new(@temp_file.path)

    # Should not raise exception
    assert_nothing_raised do
      result = service.perform
      # May succeed or fail, but should not crash
      assert [true, false].include?(result)
    end
  end

  test "should handle processing errors during CSV iteration" do
    CSV.open(@temp_file.path, "w", write_headers: true, headers: ["name", "email"]) do |csv|
      csv << ["Valid Employee", "valid@example.com"]
    end

    service = EmployeeImportService.new(@temp_file.path)

    # Stub Employee.new to raise an error
    Employee.stub(:new, proc { |*args| raise StandardError, "Unexpected error" }) do
      assert_not service.perform
      assert service.errors.any? { |e| e.include?("Error processing CSV") }
    end
  end

  test "should log errors when processing fails" do
    CSV.open(@temp_file.path, "w", write_headers: true, headers: ["name", "email"]) do |csv|
      csv << ["Test", "test@example.com"]
    end

    service = EmployeeImportService.new(@temp_file.path)

    Employee.stub(:new, proc { |*args| raise StandardError, "Test error" }) do
      Rails.logger.expects(:error).at_least_once

      service.perform
    end
  end

  test "should validate file existence before processing" do
    service = EmployeeImportService.new("/fake/path/file.csv")

    result = service.perform

    assert_not result
    assert_not service.errors.empty?
    assert service.errors.first.include?("File not found") || service.errors.first.include?("not found")
  end

  test "should handle valid CSV successfully" do
    CSV.open(@temp_file.path, "w", write_headers: true, headers: ["name", "email", "company_id"]) do |csv|
      csv << ["Test Employee", "test@example.com", @company.id.to_s]
    end

    service = EmployeeImportService.new(@temp_file.path)

    assert service.perform
    assert_equal 0, service.errors.count
  end
end
