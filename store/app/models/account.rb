class Account < ApplicationRecord
  has_secure_password

  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP, message: "Not a valid email address"}

  # Only validate password if creating OR changing password
  validates :password, 
    length: { minimum: 8, message: "Password too short. Minimun of 8 characters." },
    confirmation: { message: "Password does not match." },
    format: { with: /\A(?=.*[0-9])(?=.*[^A-Za-z0-9]).+\z/, message: "Must contain at least 1 symbol and 1 number" },
    if: :password_required?

  private

  def password_required?
    new_record? || password.present?
  end
end
