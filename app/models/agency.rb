class Agency < ApplicationRecord
  has_many :agents, dependent: :destroy
  validates :name, :email, :poc_email, presence: true

  accepts_nested_attributes_for :agents, allow_destroy: true

  after_create :create_user_with_poc_email

  private

  def create_user_with_poc_email
    first_part_of_email = poc_email.split("@").first
    random_password = SecureRandom.hex(8)
    user = User.create(
      email: poc_email,
      name: first_part_of_email.capitalize,
      password: random_password,
      role: "agent"
    )
    UserMailer.welcome_email(user, name, random_password).deliver_later
  end
end
