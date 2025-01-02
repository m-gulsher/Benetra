class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true

  ROLES = %w[admin agent employee].freeze

  validates :role, inclusion: { in: ROLES }

  after_create :assign_role

  private

  def assign_role
    case role
    when 'admin'
      create_admin
    when 'agent'
      create_agent
    when 'employee'
      create_employee
    end
  end

  def create_admin
    Admin.create(email: email, name: name, user: self)
  end

  def create_agent
    Agent.create(email: email, name: name, user: self)
  end

  def create_employee
    Employee.create(email: email, name: name, user: self)
  end
end
