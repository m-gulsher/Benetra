class AgenciesController < ApplicationController
  before_action :set_agency, only: %i[show edit update destroy]

  def index
    @agencies = Agency.all
  end

  def show
  end

  def new
    @agency = Agency.new
    @agency.agents.build
  end

  def edit
    @agency.agents.build if @agency.agents.empty?
  end

  def create
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

  def agency_params
    params.require(:agency).permit(
      :name, :email, :phone, :poc_email,
      agents_attributes: [ :id, :name, :email, :_destroy ]
    )
  end
end
