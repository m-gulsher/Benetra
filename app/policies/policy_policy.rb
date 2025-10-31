class PolicyPolicy < ApplicationPolicy
  def index?
    user.admin? || user.agent? || user.employee?
  end

  def show?
    user.admin? || owns_policy? || employee_has_access?
  end

  def create?
    user.admin? || user.agent?
  end

  def update?
    user.admin? || owns_policy?
  end

  def destroy?
    user.admin? || owns_policy?
  end

  private

  def owns_policy?
    user.agent? && record.agent_id == user.authenticatable_id
  end

  def employee_has_access?
    return false unless user.employee?

    employee = user.authenticatable
    return false unless employee

    record.company_id == employee.company_id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.agent?
        agent = user.authenticatable
        return scope.none unless agent

        scope.where(agent_id: agent.id)
      elsif user.employee?
        employee = user.authenticatable
        return scope.none unless employee&.company_id

        scope.where(company_id: employee.company_id)
      else
        scope.none
      end
    end
  end
end
