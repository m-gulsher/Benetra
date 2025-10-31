require "csv"

class EmployeeImportService
  attr_reader :errors, :successful_count, :failed_count

  def initialize(file_path)
    @file_path = file_path
    @errors = []
    @import_errors = []
    @total_rows = 0
    @successful_count = 0
    @failed_count = 0
  end

  def self.total_rows
    Rails.cache.read("total_rows") || 0
  end

  def perform
    return false unless validate_file

    begin
      rows = read_csv_file
      @total_rows = rows.size

      if @total_rows.zero?
        @errors << "CSV file is empty"
        return false
      end

      initialize_cache

      process_rows(rows)

      finalize_cache
      true
    rescue StandardError => e
      Rails.logger.error("EmployeeImportService error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      @errors << "Import failed: #{e.message}"
      false
    end
  end

  private

  def validate_file
    unless File.exist?(@file_path)
      @errors << "File not found: #{@file_path}"
      return false
    end

    unless File.extname(@file_path).downcase == ".csv"
      @errors << "Invalid file format. Expected CSV file."
      return false
    end

    true
  end

  def read_csv_file
    CSV.read(@file_path, headers: true)
  rescue CSV::MalformedCSVError => e
    @errors << "Invalid CSV format: #{e.message}"
    raise
  rescue StandardError => e
    @errors << "Failed to read file: #{e.message}"
    raise
  end

  def initialize_cache
    Rails.cache.write("total_rows", @total_rows)
    Rails.cache.write("employee_import_progress", 0)
    Rails.cache.write("employee_import_errors", [])
  end

  def process_rows(rows)
    rows.each.with_index(1) do |row, index|
      process_row(row, index)
      update_progress(index)
    end
  end

  def process_row(row, index)
    employee_data = row.to_hash.symbolize_keys

    validate_and_clean_data(employee_data, index)

    employee = Employee.new(employee_data)

    if employee.save
      @successful_count += 1
    else
      @failed_count += 1
      error_message = employee.errors.full_messages.join(", ")
      add_import_error(index, error_message)
    end
  rescue StandardError => e
    @failed_count += 1
    Rails.logger.error("Error processing row #{index}: #{e.message}")
    add_import_error(index, "Unexpected error: #{e.message}")
  end

  def validate_and_clean_data(employee_data, index)
    company_id = employee_data[:company_id] || employee_data["company_id"]

    if company_id.present?
      company_id = company_id.to_i
      unless Company.exists?(company_id)
        add_import_error(index, "Company with ID #{company_id} does not exist.")
        employee_data.delete(:company_id)
        employee_data.delete("company_id")
      end
    end

    user_id = employee_data[:user_id] || employee_data["user_id"]

    if user_id.present?
      user_id = user_id.to_i
      unless User.exists?(user_id)
        add_import_error(index, "User with ID #{user_id} does not exist.")
        employee_data.delete(:user_id)
        employee_data.delete("user_id")
      end
    end
  end

  def add_import_error(row_index, message)
    @import_errors << { row: row_index, message: message }
    update_cache_errors
  end

  def update_cache_errors
    Rails.cache.write("employee_import_errors", @import_errors)
  end

  def update_progress(index)
    progress = ((index.to_f / @total_rows) * 100).round
    Rails.cache.write("employee_import_progress", progress)
  end

  def finalize_cache
    Rails.cache.write("employee_import_progress", 100)
    update_cache_errors
  end
end
