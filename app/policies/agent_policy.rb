class AgentPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || owns_agent?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || owns_agent?
  end

  def destroy?
    user.admin?
  end

  private

  def owns_agent?
    user.agent? && record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.agent?
        agent = user.authenticatable
        return scope.none unless agent

        scope.where(id: agent.id)
      else
        scope.none
      end
    end
  end
end
