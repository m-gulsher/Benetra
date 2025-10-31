class Company < ApplicationRecord
  has_many :employees, dependent: :destroy
  has_many :policies, dependent: :destroy

  validates :name, :email, :poc_email, presence: true

  accepts_nested_attributes_for :employees, allow_destroy: true
  accepts_nested_attributes_for :policies, allow_destroy: true

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
        role: "employee",
        company_id: id
      )

      unless service.call
        Rails.logger.error("Failed to create user for company #{id}: #{service.errors.join(', ')}")
        raise ActiveRecord::Rollback
      end
    rescue StandardError => e
      Rails.logger.error("Error in create_user_with_poc_email for company #{id}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      raise ActiveRecord::Rollback
    end
  end
end
