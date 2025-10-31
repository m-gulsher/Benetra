class EmployeePolicy < ApplicationPolicy
  def index?
    user.admin? || user.agent? || user.employee?
  end

  def show?
    user.admin? || owns_employee? || agent_has_access?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || owns_employee?
  end

  def destroy?
    user.admin?
  end

  private

  def owns_employee?
    user.employee? && record.user_id == user.id
  end

  def agent_has_access?
    return false unless user.agent?

    agent = user.authenticatable
    return false unless agent

    record.company_id && agent.policies.exists?(company_id: record.company_id)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.agent?
        agent = user.authenticatable
        return scope.none unless agent

        company_ids = agent.policies.pluck(:company_id).compact.uniq
        scope.where(company_id: company_ids)
      elsif user.employee?
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end
end
