class Agent < ApplicationRecord
  belongs_to :agency
  has_one :user, as: :authenticatable, dependent: :destroy
  accepts_nested_attributes_for :user

  validates :name, :email, presence: true
  validates :email, uniqueness: true
end
