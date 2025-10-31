class Agency < ApplicationRecord
  include Searchable
  include EmailValidatable

  has_many :agents, dependent: :destroy
  validates :name, :email, :poc_email, presence: true
  validates :email, format: { with: EmailValidatable::EMAIL_REGEX, message: "must be a valid email address" }
  validates :poc_email, format: { with: EmailValidatable::EMAIL_REGEX, message: "must be a valid email address" }

  accepts_nested_attributes_for :agents, allow_destroy: true

  after_create :create_user_with_poc_email

  private

  def create_user_with_poc_email
    existing_user = User.find_by(email: poc_email)

    if existing_user
      UserMailer.reminder_email(existing_user).deliver_later
      return
    end

    first_part_of_email = poc_email.split("@").first

    ActiveRecord::Base.transaction do
      service = UserCreationService.new(
        email: poc_email,
        name: first_part_of_email.capitalize,
        role: "agent",
        agency_id: id
      )

      unless service.call
        Rails.logger.error("Failed to create user for agency #{id}: #{service.errors.join(', ')}")
        raise ActiveRecord::Rollback
      end
    rescue StandardError => e
      Rails.logger.error("Error in create_user_with_poc_email for agency #{id}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      raise ActiveRecord::Rollback
    end
  end
end
