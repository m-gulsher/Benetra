class PoliciesController < ApplicationController
  before_action :set_policy, only: %i[ show edit update destroy ]
  before_action :set_companies_and_agents, only: %i[ new edit ]

  def index
    @policies = Policy.all
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
