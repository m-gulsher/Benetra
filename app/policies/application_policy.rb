class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.admin? || has_access?
  end

  def show?
    user.admin? || has_access?
  end

  def create?
    user.admin? || can_create?
  end

  def new?
    create?
  end

  def update?
    user.admin? || owns_resource?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin? || owns_resource?
  end

  private

  def has_access?
    false
  end

  def can_create?
    false
  end

  def owns_resource?
    false
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
