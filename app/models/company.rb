class Company < ApplicationRecord
  has_many :employees, dependent: :destroy
  has_many :policies, dependent: :destroy

  validates :name, :email, :poc_email, presence: true
end