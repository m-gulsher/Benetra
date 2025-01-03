class Admin < ApplicationRecord
  has_one :user, as: :authenticatable, dependent: :destroy
  accepts_nested_attributes_for :user

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  after_create :set_as_authenticatable_for_user

  private

  def set_as_authenticatable_for_user
    user.update(authenticatable_type: "Admin", authenticatable_id: self.id)
  end
end
