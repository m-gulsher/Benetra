ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "bcrypt"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all

    setup do
      User.find_each do |user|
        user.update(encrypted_password: BCrypt::Password.create(user.password).to_s)
      end
    end
  end
end
