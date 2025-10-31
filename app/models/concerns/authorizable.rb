module Authorizable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :can?, :authorize!, :user_role if respond_to?(:helper_method)
  end

  def user_role
    current_user&.role
  end

  def admin?
    user_role == "admin"
  end

  def agent?
    user_role == "agent"
  end

  def employee?
    user_role == "employee"
  end

  def can?(action, resource = nil)
    return false unless current_user

    case action.to_sym
    when :manage
      admin?
    when :index, :show, :new, :create, :edit, :update, :destroy
      can_perform_action?(action, resource)
    else
      can_perform_action?(action, resource)
    end
  end

  def authorize!(action, resource = nil)
    unless can?(action, resource)
      redirect_to root_path, alert: "You are not authorized to perform this action."
      return false
    end
    true
  end

  def require_admin!
    unless admin?
      redirect_to root_path, alert: "Admin access required."
      return false
    end
    true
  end

  def require_agent!
    unless agent?
      redirect_to root_path, alert: "Agent access required."
      return false
    end
    true
  end

  def require_employee!
    unless employee?
      redirect_to root_path, alert: "Employee access required."
      return false
    end
    true
  end

  def require_authenticated_user!
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "Please sign in to continue."
      return false
    end
    true
  end

  def owns_resource?(resource)
    return false unless current_user && resource

    case user_role
    when "admin"
      true
    when "agent"
      owns_agent_resource?(resource)
    when "employee"
      owns_employee_resource?(resource)
    else
      false
    end
  end

  private

  def can_perform_action?(action, resource)
    return false unless current_user

    case user_role
    when "admin"
      true
    when "agent"
      agent_can?(action, resource)
    when "employee"
      employee_can?(action, resource)
    else
      false
    end
  end

  def agent_can?(action, resource)
    case action.to_sym
    when :index, :show
      case resource&.class&.name
      when "Agent"
        resource&.user_id == current_user&.id
      when "Policy"
        resource&.agent_id == current_user&.authenticatable_id
      when "Company"
        true # Agents can view companies associated with their policies
      when "Employee"
        true # Agents can view employees associated with their policies
      when "Agency"
        current_user&.authenticatable&.agency_id == resource&.id rescue false
      else
        true
      end
    when :edit, :update, :destroy
      case resource&.class&.name
      when "Agent"
        resource&.user_id == current_user&.id
      when "Policy"
        resource&.agent_id == current_user&.authenticatable_id
      else
        false
      end
    when :new, :create
      resource == Policy
    else
      false
    end
  end

  def employee_can?(action, resource)
    case action.to_sym
    when :index, :show
      case resource&.class&.name
      when "Employee"
        resource&.user_id == current_user&.id
      when "Company"
        current_user&.authenticatable&.company_id == resource&.id rescue false
      when "Policy"
        resource&.company_id == current_user&.authenticatable&.company_id rescue false
      else
        false
      end
    when :edit, :update
      case resource&.class&.name
      when "Employee"
        resource&.user_id == current_user&.id
      else
        false
      end
    else
      false
    end
  end

  def owns_agent_resource?(resource)
    return false unless current_user&.authenticatable

    case resource.class.name
    when "Agent"
      resource.user_id == current_user.id
    when "Policy"
      resource.agent_id == current_user.authenticatable_id
    when "Company"
      current_user.authenticatable.policies.exists?(company_id: resource.id) rescue false
    when "Employee"
      current_user.authenticatable.policies.joins(:company).where(companies: { id: resource.company_id }).exists? rescue false
    when "Agency"
      current_user.authenticatable.agency_id == resource.id rescue false
    else
      false
    end
  end

  def owns_employee_resource?(resource)
    return false unless current_user&.authenticatable

    case resource.class.name
    when "Employee"
      resource.user_id == current_user.id
    when "Company"
      resource.id == current_user.authenticatable.company_id rescue false
    when "Policy"
      resource.company_id == current_user.authenticatable.company_id rescue false
    else
      false
    end
  end
end
