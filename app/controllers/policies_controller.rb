class PoliciesController < ApplicationController
  before_action :set_policy, only: %i[ show edit update destroy ]
  before_action :set_companies_and_agents, only: %i[ new edit ]
  before_action :authorize_policy_action!, only: %i[ index show edit update destroy ]
  before_action :authorize_create!, only: %i[ new create ]

  def index
    search_term = params[:search]&.strip
    company_id = params[:company_id]
    agent_id = params[:agent_id]
    page = params[:page] || 1
    per_page = params[:per_page] || 20

    base_scope = PolicyPolicy::Scope.new(current_user, Policy).resolve
    @policies = base_scope.search_and_filter(
      search_term,
      { company_id: company_id, agent_id: agent_id },
      :name,
      :description
    ).includes(:company, :agent)

    @total_count = @policies.count
    @total_pages = @policies.total_pages(per_page: per_page.to_i)
    @policies = @policies.paginated(page: page, per_page: per_page)

    # Set companies and agents for filter dropdowns (respecting authorization)
    if admin?
      @companies = Company.all.order(:name)
      @agents = Agent.all.order(:name)
    elsif agent?
      @companies = CompanyPolicy::Scope.new(current_user, Company).resolve.order(:name)
      @agents = [current_user.authenticatable]
    else
      @companies = CompanyPolicy::Scope.new(current_user, Company).resolve.order(:name)
      @agents = Agent.none
    end

    @current_search = search_term
    @current_company_id = company_id
    @current_agent_id = agent_id
    @current_page = page.to_i
    @per_page = per_page.to_i
  end

  def show
    authorize!(:show, @policy)
  end

  def new
    authorize!(:new, Policy)
    @policy = Policy.new
    @policy.agent_id = current_user.authenticatable_id if agent?
  end

  def edit
    authorize!(:edit, @policy)
  end

  def create
    authorize!(:create, Policy)
    @policy = Policy.new(policy_params)
    @policy.agent_id = current_user.authenticatable_id if agent? && !admin?

    if @policy.save
      redirect_to policies_path, notice: "Policy was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize!(:update, @policy)
    if @policy.update(policy_params)
      redirect_to policies_path, notice: "Policy was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize!(:destroy, @policy)
    @policy.destroy
    redirect_to policies_url, notice: "Policy was successfully destroyed."
  end

  private

  def set_policy
    @policy = Policy.find(params[:id])
  end

  def set_companies_and_agents
    if admin?
      @companies = Company.all
      @agents = Agent.all
    elsif agent?
      @companies = CompanyPolicy::Scope.new(current_user, Company).resolve
      @agents = [current_user.authenticatable]
    else
      @companies = CompanyPolicy::Scope.new(current_user, Company).resolve
      @agents = Agent.none
    end
  end

  def authorize_policy_action!
    action = action_name.to_sym
    resource = action == :index ? Policy : @policy
    authorize!(action, resource)
  end

  def authorize_create!
    authorize!(:create, Policy)
  end

  def policy_params
    params.require(:policy).permit(:name, :description, :company_id, :agent_id)
  end
end
