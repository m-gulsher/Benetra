require "csv"

class EmployeeImportService
  attr_reader :errors

  def initialize(file_path)
    @file_path = file_path
    @errors = []
    @total_rows = 0
  end

  def self.total_rows
    Rails.cache.read("total_rows") || 0
  end

  def perform
    total_rows = CSV.read(@file_path, headers: true).size
    Rails.cache.write("total_rows", total_rows)

    return false if total_rows.zero?

    Rails.cache.write("employee_import_progress", 0)
    Rails.cache.write("employee_import_errors", [])

    CSV.foreach(@file_path, headers: true).with_index(1) do |row, index|
      employee_data = row.to_hash
      company_id = employee_data["company_id"]
      user_id = employee_data["user_id"]

      if company_id.present? && !Company.exists?(company_id)
        Rails.cache.write("employee_import_errors", Rails.cache.read("employee_import_errors") + [ { row: index, message: "Company with ID #{company_id} does not exist." } ])
        employee_data.delete("company_id")
      end

      if user_id.present? && !User.exists?(user_id)
        Rails.cache.write("employee_import_errors", Rails.cache.read("employee_import_errors") + [ { row: index, message: "User with ID #{user_id} does not exist." } ])
        employee_data.delete("user_id")
      end

      employee = Employee.new(employee_data)

      unless employee.save
        Rails.cache.write("employee_import_errors", Rails.cache.read("employee_import_errors") + [ { row: index, message: employee.errors.full_messages.join(", ") } ])
      end

      progress = ((index.to_f / total_rows) * 100).round
      Rails.cache.write("employee_import_progress", progress)
    end

    true
  end
end
