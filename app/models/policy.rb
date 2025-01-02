class Policy < ApplicationRecord
  belongs_to :company
  belongs_to :agent

  validates :name, presence: true
  validates :description, presence: true
end
