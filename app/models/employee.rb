class Employee < ApplicationRecord
  include Searchable
  include EmailValidatable

  belongs_to :company, optional: true
  has_one :user, as: :authenticatable, required: false
  accepts_nested_attributes_for :user

  validates :name, :email, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: EmailValidatable::EMAIL_REGEX, message: "must be a valid email address" }

  after_create :set_as_authenticatable_for_user

  private

  def set_as_authenticatable_for_user
    return unless user

    unless user.update(authenticatable_type: "Employee", authenticatable_id: self.id)
      Rails.logger.error("Failed to update user #{user.id} authenticatable for employee #{self.id}: #{user.errors.full_messages.join(', ')}")
    end
  end
end
