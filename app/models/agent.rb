class Agent < ApplicationRecord
  belongs_to :agency, optional: true
  has_one :user, as: :authenticatable, required: false
  has_many :policies, dependent: :destroy
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :policies

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  after_create :set_as_authenticatable_for_user

  private

  def set_as_authenticatable_for_user
    return unless user

    unless user.update(authenticatable_type: "Agent", authenticatable_id: self.id)
      Rails.logger.error("Failed to update user #{user.id} authenticatable for agent #{self.id}: #{user.errors.full_messages.join(', ')}")
    end
  end
end
