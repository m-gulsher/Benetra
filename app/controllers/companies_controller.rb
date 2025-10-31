class CompaniesController < ApplicationController
  before_action :set_company, only: %i[ show edit update destroy ]
  before_action :authorize_company_action!, only: %i[ index show edit update destroy ]
  before_action :authorize_create!, only: %i[ new create ]

  def index
    search_term = params[:search]&.strip
    page = params[:page] || 1
    per_page = params[:per_page] || 20

    base_scope = CompanyPolicy::Scope.new(current_user, Company).resolve
    @companies = base_scope.search_and_filter(
      search_term,
      {},
      :name,
      :email,
      :poc_email
    )

    @total_count = @companies.count
    @total_pages = @companies.total_pages(per_page: per_page.to_i)
    @companies = @companies.paginated(page: page, per_page: per_page)

    @current_search = search_term
    @current_page = page.to_i
    @per_page = per_page.to_i
  end

  def show
    authorize!(:show, @company)
  end

  def new
    authorize!(:new, Company)
    @company = Company.new
    @company.employees.build
  end

  def edit
    authorize!(:edit, @company)
    @company.employees.build if @company.employees.empty?
  end

  def create
    authorize!(:create, Company)
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: "Company was successfully created." }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize!(:update, @company)
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: "Company was successfully updated." }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize!(:destroy, @company)
    @company.destroy!

    respond_to do |format|
      format.html { redirect_to companies_path, status: :see_other, notice: "Company was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_company
      @company = Company.find(params.expect(:id))
    end

    def authorize_company_action!
      action = action_name.to_sym
      resource = action == :index ? Company : @company
      authorize!(action, resource)
    end

    def authorize_create!
      authorize!(:create, Company)
    end

    def company_params
      params.require(:company).permit(
        :name, :email, :phone, :poc_email,
        employees_attributes: [ :id, :name, :email, :_destroy ]
      )
    end
end
