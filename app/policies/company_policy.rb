class CompanyPolicy < ApplicationPolicy
  def index?
    user.admin? || user.agent? || user.employee?
  end

  def show?
    user.admin? || owns_company? || agent_has_access?
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

  def owns_company?
    user.employee? && record.id == user.authenticatable&.company_id
  end

  def agent_has_access?
    return false unless user.agent?

    agent = user.authenticatable
    return false unless agent

    agent.policies.exists?(company_id: record.id)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.agent?
        agent = user.authenticatable
        return scope.none unless agent

        company_ids = agent.policies.pluck(:company_id).compact.uniq
        scope.where(id: company_ids)
      elsif user.employee?
        employee = user.authenticatable
        return scope.none unless employee&.company_id

        scope.where(id: employee.company_id)
      else
        scope.none
      end
    end
  end
end
