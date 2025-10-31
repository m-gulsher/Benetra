class PoliciesController < ApplicationController
  before_action :set_policy, only: %i[ show edit update destroy ]
  before_action :set_companies_and_agents, only: %i[ new edit ]

  def index
    search_term = params[:search]&.strip
    company_id = params[:company_id]
    agent_id = params[:agent_id]
    page = params[:page] || 1
    per_page = params[:per_page] || 20

    @policies = Policy.search_and_filter(
      search_term,
      { company_id: company_id, agent_id: agent_id },
      :name,
      :description
    ).includes(:company, :agent)

    @total_count = @policies.count
    @total_pages = @policies.total_pages(per_page: per_page.to_i)
    @policies = @policies.paginated(page: page, per_page: per_page)

    @companies = Company.all.order(:name)
    @agents = Agent.all.order(:name)
    @current_search = search_term
    @current_company_id = company_id
    @current_agent_id = agent_id
    @current_page = page.to_i
    @per_page = per_page.to_i
  end

  def show
  end

  def new
    @policy = Policy.new
  end

  def edit
  end

  def create
    @policy = Policy.new(policy_params)

    if @policy.save
      redirect_to policies_path, notice: "Policy was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @policy.update(policy_params)
      redirect_to policies_path, notice: "Policy was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @policy.destroy
    redirect_to policies_url, notice: "Policy was successfully destroyed."
  end

  private

  def set_policy
    @policy = Policy.find(params[:id])
  end

  def set_companies_and_agents
    @companies = Company.all
    @agents = Agent.all
  end

  def policy_params
    params.require(:policy).permit(:name, :description, :company_id, :agent_id)
  end
end
