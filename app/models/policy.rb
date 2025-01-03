class Policy < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :agent, optional: true

  validates :name, presence: true
  validates :description, presence: true
end
