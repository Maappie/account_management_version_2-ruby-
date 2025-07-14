class VerificationCodeMailer < ApplicationMailer
  default from: 'renzmapa0321@gmail.com'

  def verification_mail(email, code)
    @code = code
    mail(to: email, subject: 'Verification code')
  end

  def reset_password_code_mail(email, code)
    @code = code
    mail(to: email, subject: 'Verification code')
  end
end

