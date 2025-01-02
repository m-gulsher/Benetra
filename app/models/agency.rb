class Agency < ApplicationRecord
  has_many :agents, dependent: :destroy
  validates :name, :email, :poc_email, presence: true
end
