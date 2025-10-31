class AgenciesController < ApplicationController
  before_action :set_agency, only: %i[show edit update destroy]
  before_action :authorize_agency_action!, only: %i[ index show edit update destroy ]
  before_action :authorize_create!, only: %i[ new create ]

  def index
    base_scope = AgencyPolicy::Scope.new(current_user, Agency).resolve
    @agencies = base_scope
  end

  def show
    authorize!(:show, @agency)
  end

  def new
    authorize!(:new, Agency)
    @agency = Agency.new
    @agency.agents.build
  end

  def edit
    authorize!(:edit, @agency)
    @agency.agents.build if @agency.agents.empty?
  end

  def create
    authorize!(:create, Agency)
    @agency = Agency.new(agency_params)

    respond_to do |format|
      if @agency.save
        format.html { redirect_to agencies_path, notice: "Agency was successfully created." }
        format.json { render :show, status: :created, location: @agency }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @agency.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize!(:update, @agency)
    respond_to do |format|
      if @agency.update(agency_params)
        format.html { redirect_to agencies_path, notice: "Agency was successfully updated." }
        format.json { render :show, status: :ok, location: @agency }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @agency.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize!(:destroy, @agency)
    @agency.destroy

    respond_to do |format|
      format.html { redirect_to agencies_path, status: :see_other, notice: "Agency was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_agency
    @agency = Agency.find(params[:id])
  end

  def authorize_agency_action!
    action = action_name.to_sym
    resource = action == :index ? Agency : @agency
    authorize!(action, resource)
  end

  def authorize_create!
    authorize!(:create, Agency)
  end

  def agency_params
    params.require(:agency).permit(
      :name, :email, :phone, :poc_email,
      agents_attributes: [ :id, :name, :email, :_destroy ]
    )
  end
end
