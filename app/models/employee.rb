class Employee < ApplicationRecord
  belongs_to :company, optional: true
  has_one :user, as: :authenticatable, required: false
  accepts_nested_attributes_for :user

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  after_create :set_as_authenticatable_for_user

  private

  def set_as_authenticatable_for_user
    return unless user

    user.update(authenticatable_type: "Employee", authenticatable_id: self.id)
  end
end
