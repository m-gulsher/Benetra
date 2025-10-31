class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true

  ROLES = %w[admin agent employee].freeze

  validates :role, inclusion: { in: ROLES }

  after_create :create_admin

  def admin?
    role == "admin"
  end

  def agent?
    role == "agent"
  end

  def employee?
    role == "employee"
  end

  private

  def create_admin
    return unless role == "admin"

    Admin.create(email: email, name: name, user: self)
  end
end
