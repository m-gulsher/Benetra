class Agent < ApplicationRecord
  belongs_to :agency
  has_one :user, as: :authenticatable, dependent: :destroy
  accepts_nested_attributes_for :user

  validates :name, :email, presence: true
  validates :email, uniqueness: true
  after_create :set_as_authenticatable_for_user

  private

  # Set this agent as the authenticatable for the user
  def set_as_authenticatable_for_user
    user.update(authenticatable_type: 'Agent', authenticatable_id: self.id)
  end
end
