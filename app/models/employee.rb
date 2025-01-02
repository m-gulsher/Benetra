class Employee < ApplicationRecord
  belongs_to :company
  has_one :user, as: :authenticatable, dependent: :destroy
  accepts_nested_attributes_for :user

  validates :name, :email, presence: true
  validates :email, uniqueness: true
end
