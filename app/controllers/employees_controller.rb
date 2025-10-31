class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[ show edit update destroy ]

  def index
    @employees = Employee.all
  end

  def show
  end

  def new
    @employee = Employee.new
  end

  def edit
  end

  def create
    @employee = Employee.new(employee_params)

    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: "Employee was successfully created." }
        format.json { render :show, status: :created, location: @employee }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to @employee, notice: "Employee was successfully updated." }
        format.json { render :show, status: :ok, location: @employee }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @employee.destroy!

    respond_to do |format|
      format.html { redirect_to employees_path, status: :see_other, notice: "Employee was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def import
    @progress = 0
  end

  def import_csv
    csv_file = params[:file]
    if csv_file.blank? || File.extname(csv_file.original_filename) != ".csv"
      redirect_to import_employees_path, alert: "Please upload a valid CSV file."
      return
    end

    import_service = EmployeeImportService.new(csv_file.path)
    if import_service.perform
      redirect_to employees_path, notice: "Employees imported successfully!"
    else
      redirect_to import_employees_path, alert: import_service.errors.join(", ")
    end
  end

  def import_progress
    progress = Rails.cache.read("employee_import_progress") || 0
    render json: { progress: progress, messages: [] }
  end

  def import_results
    errors = Rails.cache.read("employee_import_errors") || []
    total_rows = EmployeeImportService.total_rows
    results = []

    error_rows = errors.map { |e| e[:row] }.to_set
    success_rows = (1..total_rows).to_set - error_rows

    errors.each do |error|
      results << { row: error[:row], success: false, error: error[:message] }
    end

    success_rows.each do |row|
      results << { row: row, success: true, error: nil }
    end

    results.sort_by! { |r| r[:row] }

    render json: { results: results }
  end

  private
    def set_employee
      @employee = Employee.find(params.expect(:id))
    end

    def employee_params
      params.require(:employee).permit(:name, :email, :phone, :company_id)
    end
end
