class ResetPasswordController < ApplicationController
  before_action -> { require_session_key(:reset_password_id) }, only: [:verify_reset_code, :verify_reset_code_page]
  before_action -> { require_session_key(:update_password) }, only: [:edit, :update]

  def new
  end

  def create
    account = Account.find_by(email: params[:email])

    if account.present? && account.verified == true
      if account.update(verification_code: generate_verification_code)
        if account.save
          send_email_forgot_password(account)
        else
          flash[:alert] = "Something went wrong. Try again."
          redirect_to new_reset_password_path and return
        end
      else
        flash[:alert] = "Something went wrong. Try again. (2)" # the number is for debugging only
        redirect_to new_reset_password_path and return
      end
    else
      flash[:alert] = "No account found. "
      redirect_to new_reset_password_path and return
    end

  end

  def edit
    # show the forms to process by method 'update'
    @account = Account.find(params[:id])

  rescue ActiveRecord::RecordNotFound
      flash[:alert] = "Account not found."
      redirect_to new_reset_password_path and return
    
  end

  def update
    @account = Account.find(params[:id])

    if @account.update(account_params.merge(verification_code: nil)) 
      end_session
      session[:update_password] = nil
      flash[:notice] = "Password changed."
      redirect_to root_path and return
    else
      flash.now[:alert] = "Failed to update password."
      flash[:errors] = @account.errors.map(&:message)
      redirect_to edit_reset_password_path(@account)
    end
  end

  def verify_reset_code_page
  # shows the verification page for a reset password request
  end

  def verify_reset_code
    input_code = params[:verification_code]
    account = Account.find_by(verification_code: input_code)

    if session[:reset_password_code_expires_at].blank? || session[:reset_password_code_expires_at] < Time.current
      flash[:alert] = "Change password verification code expired."
      end_session
      redirect_to new_reset_password_path	and return
    end

    if account.present?
      if input_code == session[:reset_password_code]
          session[:update_password] = true
          flash[:notice] = "Change password request granted."
          redirect_to edit_reset_password_path(account) and return
      end

    elsif !account.present?
        flash[:alert] = "Verification code wrong. Try again."
        redirect_to verify_reset_code_page_reset_password_index_path and return
    else
        end_session
        flash[:alert] = "Something went wrong. (3)"
        redirect_to verify_reset_code_page_reset_password_index_path and return
    end
  end

  private

  def account_params
    params.permit(:password, :password_confirmation)
  end

  def send_email_forgot_password(account)
    generate_session(account)

    begin
      VerificationCodeMailer.reset_password_code_mail(account.email, account.verification_code).deliver_now
      flash[:alert] = "Verification Sent 1"
      redirect_to verify_reset_code_page_reset_password_index_path and return
    rescue => e 
      Rails.logger.error "Email send failed: #{e.class} - #{e.message}"
      flash[:alert] = "Sending email failed: #{e.message}"
      end_session
      redirect_to new_reset_password_path and return
    end
  end


  def generate_verification_code
    loop do
      code = rand(100000..999999).to_s
      return code unless Account.exists?(verification_code: code)
    end     
  end

  def generate_session(account)
    session[:reset_password_id] = account.id
    session[:reset_password_code] = account.verification_code
    session[:reset_password_code_expires_at] = 3000.seconds.from_now
  end

  def end_session
    session.delete(:reset_password_id)
    session.delete(:reset_password_code)
    session.delete(:reset_password_code_expires_at)
  end
end
