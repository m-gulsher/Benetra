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

  private

  def create_admin
    return unless role == "admin"

    Admin.create(email: email, name: name, user: self)
  end

  def create_agent
    Agent.create(email: email, name: name, user: self)
  end

  def create_employee
    employee = Employee.create(email: email, name: name, user_id: self.id)
    self.update(authenticatable_type: "Employee", authenticatable_id: employee.id)
  end
end
