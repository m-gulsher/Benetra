class AgencyPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || agent_belongs_to_agency?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  private

  def agent_belongs_to_agency?
    return false unless user.agent?

    agent = user.authenticatable
    return false unless agent

    agent.agency_id == record.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.agent?
        agent = user.authenticatable
        return scope.none unless agent&.agency_id

        scope.where(id: agent.agency_id)
      else
        scope.none
      end
    end
  end
end
