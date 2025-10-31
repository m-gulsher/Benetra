require "test_helper"

class EmployeeImportServiceTest < ActiveSupport::TestCase
  setup do
    @company = companies(:one)
    @temp_file = Tempfile.new(["test_employees", ".csv"])
    Rails.cache.clear
  end

  teardown do
    @temp_file&.close
    @temp_file&.unlink
    Rails.cache.clear
  end

  test "should read CSV file only once" do
    CSV.open(@temp_file.path, "w", write_headers: true, headers: ["name", "email", "company_id"]) do |csv|
      csv << ["John Doe", "john@example.com", @company.id.to_s]
      csv << ["Jane Smith", "jane@example.com", @company.id.to_s]
    end

    service = EmployeeImportService.new(@temp_file.path)

    # Mock CSV.read to track calls
    call_count = 0
    CSV.stub(:read, ->(*args) { call_count += 1; CSV.read(*args) }) do
      service.perform
    end

    # Should be called only once (in read_csv_file)
    assert_equal 1, call_count, "CSV file should be read only once"
  end

  test "should use efficient cache operations" do
    CSV.open(@temp_file.path, "w", write_headers: true, headers: ["name", "email"]) do |csv|
      5.times { |i| csv << ["Employee #{i}", "emp#{i}@example.com"] }
    end

    service = EmployeeImportService.new(@temp_file.path)

    cache_write_count = 0
    original_write = Rails.cache.method(:write)
    Rails.cache.define_singleton_method(:write) do |*args|
      cache_write_count += 1
      original_write.call(*args)
    end

    service.perform

    # Should write cache efficiently (not read-modify-write in loop)
    assert cache_write_count > 0
    # Cache writes should be reasonable (not one per row for errors)
    assert cache_write_count < 20, "Cache operations should be efficient"
  end

  test "should track successful and failed imports" do
    CSV.open(@temp_file.path, "w", write_headers: true, headers: ["name", "email"]) do |csv|
      csv << ["Valid Employee", "valid@example.com"]
      csv << ["", "invalid@example.com"] # Missing name - should fail
      csv << ["Another Valid", "another@example.com"]
    end

    service = EmployeeImportService.new(@temp_file.path)
    service.perform

    assert_equal 2, service.successful_count
    assert_equal 1, service.failed_count
  end

  test "should handle file not found error" do
    service = EmployeeImportService.new("/nonexistent/file.csv")

    assert_not service.perform
    assert_includes service.errors.first, "File not found"
  end

  test "should handle invalid file format" do
    temp_file = Tempfile.new(["test", ".txt"])
    service = EmployeeImportService.new(temp_file.path)

    assert_not service.perform
    assert_includes service.errors.first, "Invalid file format"

    temp_file.close
    temp_file.unlink
  end

  test "should handle malformed CSV" do
    @temp_file.write("invalid,csv\ncontent")
    @temp_file.close

    service = EmployeeImportService.new(@temp_file.path)

    assert_not service.perform
    assert service.errors.any? { |e| e.include?("Invalid CSV format") || e.include?("CSV") }
  end

  test "should validate company_id before processing" do
    CSV.open(@temp_file.path, "w", write_headers: true, headers: ["name", "email", "company_id"]) do |csv|
      csv << ["Employee", "emp@example.com", "99999"] # Non-existent company
    end

    service = EmployeeImportService.new(@temp_file.path)
    service.perform

    errors = Rails.cache.read("employee_import_errors")
    assert errors.any? { |e| e[:message].include?("Company with ID 99999") }
  end

  test "should validate user_id before processing" do
    CSV.open(@temp_file.path, "w", write_headers: true, headers: ["name", "email", "user_id"]) do |csv|
      csv << ["Employee", "emp@example.com", "99999"] # Non-existent user
    end

    service = EmployeeImportService.new(@temp_file.path)
    service.perform

    errors = Rails.cache.read("employee_import_errors")
    assert errors.any? { |e| e[:message].include?("User with ID 99999") }
  end

  test "should handle empty CSV file" do
    CSV.open(@temp_file.path, "w", write_headers: true, headers: ["name", "email"]) do |csv|
      # No rows
    end

    service = EmployeeImportService.new(@temp_file.path)

    assert_not service.perform
  end

  test "should process valid rows successfully" do
    CSV.open(@temp_file.path, "w", write_headers: true, headers: ["name", "email", "company_id"]) do |csv|
      csv << ["John Doe", "john@example.com", @company.id.to_s]
      csv << ["Jane Smith", "jane@example.com", @company.id.to_s]
    end

    service = EmployeeImportService.new(@temp_file.path)

    assert_difference("Employee.count", 2) do
      assert service.perform
    end

    assert_equal 2, service.successful_count
    assert_equal 0, service.failed_count
  end

  test "should handle validation errors gracefully" do
    # Create duplicate email first
    Employee.create!(name: "Existing", email: "duplicate@example.com", company: @company)

    CSV.open(@temp_file.path, "w", write_headers: true, headers: ["name", "email"]) do |csv|
      csv << ["Duplicate", "duplicate@example.com"] # Should fail uniqueness
    end

    service = EmployeeImportService.new(@temp_file.path)
    service.perform

    assert_equal 0, service.successful_count
    assert_equal 1, service.failed_count
    errors = Rails.cache.read("employee_import_errors")
    assert errors.any? { |e| e[:message].include?("has already been taken") }
  end

  test "should update cache with progress" do
    CSV.open(@temp_file.path, "w", write_headers: true, headers: ["name", "email"]) do |csv|
      10.times { |i| csv << ["Employee #{i}", "emp#{i}@example.com"] }
    end

    service = EmployeeImportService.new(@temp_file.path)
    service.perform

    progress = Rails.cache.read("employee_import_progress")
    assert_equal 100, progress
  end

  test "should handle exceptions during processing" do
    CSV.open(@temp_file.path, "w", write_headers: true, headers: ["name", "email"]) do |csv|
      csv << ["Employee", "emp@example.com"]
    end

    Employee.stub_any_instance(:save, proc { raise StandardError, "Unexpected error" }) do
      service = EmployeeImportService.new(@temp_file.path)

      assert_nothing_raised do
        service.perform
      end

      assert service.errors.any? { |e| e.include?("Import failed") || e.include?("Unexpected error") }
    end
  end
end
