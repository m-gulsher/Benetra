class Agency < ApplicationRecord
  include Searchable
  include EmailValidatable

  has_many :agents, dependent: :destroy
  validates :name, :email, :poc_email, presence: true
  validates :email, format: { with: EmailValidatable::EMAIL_REGEX, message: "must be a valid email address" }
  validates :poc_email, format: { with: EmailValidatable::EMAIL_REGEX, message: "must be a valid email address" }

  accepts_nested_attributes_for :agents, allow_destroy: true

  after_create :create_user_with_poc_email

  private

  def create_user_with_poc_email
    existing_user = User.find_by(email: poc_email)

    if existing_user
      UserMailer.reminder_email(existing_user).deliver_later
    else
      first_part_of_email = poc_email.split("@").first
      random_password = SecureRandom.hex(8)
      user = User.new(
        email: poc_email,
        name: first_part_of_email.capitalize,
        password: random_password,
        role: "agent"
      )

      if user.save
        agent = Agent.create(email: email, name: name, user_id: user.id, agency_id: self.id)
        user.update(authenticatable_type: "Agent", authenticatable_id: agent.id)

        UserMailer.welcome_email(user, first_part_of_email.capitalize, random_password).deliver_later
      end
    end
  end
end
