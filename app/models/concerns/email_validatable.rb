module EmailValidatable
  extend ActiveSupport::Concern

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  included do
    validates :email, format: { with: EMAIL_REGEX, message: "must be a valid email address" }, allow_blank: true
  end

  module ClassMethods
    def validates_email_format_on(*attributes)
      attributes.each do |attribute|
        validates attribute, format: { with: EMAIL_REGEX, message: "must be a valid email address" }, allow_blank: true
      end
    end
  end
end
