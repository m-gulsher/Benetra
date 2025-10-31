class Admin < ApplicationRecord
  include EmailValidatable

  has_one :user, as: :authenticatable, dependent: :destroy
  accepts_nested_attributes_for :user

  validates :name, :email, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: EmailValidatable::EMAIL_REGEX, message: "must be a valid email address" }

  after_create :set_as_authenticatable_for_user

  private

  def set_as_authenticatable_for_user
    user.update(authenticatable_type: "Admin", authenticatable_id: self.id)
  end
end
