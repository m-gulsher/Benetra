class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true

  ROLES = %w[admin agent employee].freeze

  validates :role, inclusion: { in: ROLES }
end
