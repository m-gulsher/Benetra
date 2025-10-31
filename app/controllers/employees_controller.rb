class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[ show edit update destroy ]
  before_action :authorize_employee_action!, only: %i[ index show edit update destroy ]
  before_action :authorize_create!, only: %i[ new create ]

  def index
    search_term = params[:search]&.strip
    company_id = params[:company_id]
    page = params[:page] || 1
    per_page = params[:per_page] || 20

    base_scope = EmployeePolicy::Scope.new(current_user, Employee).resolve
    @employees = base_scope.search_and_filter(
      search_term,
      { company_id: company_id },
      :name,
      :email,
      :phone
    )

    @total_count = @employees.count
    @total_pages = @employees.total_pages(per_page: per_page.to_i)
    @employees = @employees.paginated(page: page, per_page: per_page)

    # Set companies for filter dropdown (respecting authorization)
    @companies = CompanyPolicy::Scope.new(current_user, Company).resolve.order(:name)
    @current_search = search_term
    @current_company_id = company_id
    @current_page = page.to_i
    @per_page = per_page.to_i
  end

  def show
    authorize!(:show, @employee)
  end

  def new
    authorize!(:new, Employee)
    @employee = Employee.new
  end

  def edit
    authorize!(:edit, @employee)
  end

  def create
    authorize!(:create, Employee)
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
    authorize!(:update, @employee)
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
    authorize!(:destroy, @employee)
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
    results = []

    errors.each do |error|
      results << { row: error[:row], success: false, error: error[:message] }
    end

    (errors.count + 1..EmployeeImportService.total_rows).each do |row|
      results << { row: row, success: true, error: nil }
    end

    render json: { results: results }
  end

  private
    def set_employee
      @employee = Employee.find(params.expect(:id))
    end

    def authorize_employee_action!
      action = action_name.to_sym
      resource = action == :index ? Employee : @employee
      authorize!(action, resource)
    end

    def authorize_create!
      authorize!(:create, Employee)
    end

    def employee_params
      params.require(:employee).permit(:name, :email, :phone, :company_id)
    end
end
