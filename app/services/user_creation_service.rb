class UserCreationService
  attr_reader :errors, :user, :authenticatable

  def initialize(email:, name:, role:, password: nil, company_id: nil, agency_id: nil)
    @email = email
    @name = name
    @role = role
    @password = password || SecureRandom.hex(8)
    @company_id = company_id
    @agency_id = agency_id
    @errors = []
  end

  def call
    return false unless validate_inputs

    ActiveRecord::Base.transaction do
      create_user
      return false if @errors.any?

      create_authenticatable
      return false if @errors.any?

      link_user_to_authenticatable
      return false if @errors.any?

      send_welcome_email if success?

      success?
    end
  rescue StandardError => e
    @errors << "Failed to create user: #{e.message}"
    Rails.logger.error("UserCreationService error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    false
  end

  def success?
    @errors.empty? && @user.present? && @authenticatable.present?
  end

  private

  def validate_inputs
    if @email.blank?
      @errors << "Email cannot be blank"
      return false
    end

    if @name.blank?
      @errors << "Name cannot be blank"
      return false
    end

    if @role.blank?
      @errors << "Role cannot be blank"
      return false
    end

    unless User::ROLES.include?(@role)
      @errors << "Invalid role: #{@role}"
      return false
    end

    true
  end

  def create_user
    @user = User.new(
      email: @email,
      name: @name,
      password: @password,
      role: @role
    )

    unless @user.save
      @errors.concat(@user.errors.full_messages)
      raise ActiveRecord::Rollback
    end
  end

  def create_authenticatable
    case @role
    when "employee"
      @authenticatable = Employee.new(
        email: @email,
        name: @name,
        user: @user,
        company_id: @company_id
      )
    when "agent"
      @authenticatable = Agent.new(
        email: @email,
        name: @name,
        user: @user,
        agency_id: @agency_id
      )
    when "admin"
      @authenticatable = Admin.new(
        email: @email,
        name: @name,
        user: @user
      )
    end

    unless @authenticatable&.save
      @errors.concat(@authenticatable.errors.full_messages) if @authenticatable
      raise ActiveRecord::Rollback
    end
  end

  def link_user_to_authenticatable
    return unless @user && @authenticatable

    @user.update(
      authenticatable_type: @authenticatable.class.name,
      authenticatable_id: @authenticatable.id
    )

    unless @user.save
      @errors.concat(@user.errors.full_messages)
      raise ActiveRecord::Rollback
    end
  end

  def send_welcome_email
    first_part_of_email = @email.split("@").first.capitalize
    UserMailer.welcome_email(@user, first_part_of_email, @password).deliver_later
  end
end
