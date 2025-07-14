class CreateAccountController < ApplicationController
  before_action -> { require_session_key(:create_account_id) }, only: [:verify_code, :verify_code_page]

  def index
    redirect_to new_account_path and return
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.find_by(email: account_params[:email])

    if @account.present?
      if @account.verified?
        flash[:alert] = "Email already in used."
        redirect_to new_account_path and return
      elsif !@account.verified?
        @account.assign_attributes(account_params)
        @account.verification_code = generate_verification_code
        if @account.save
          send_email(@account)
        else
          flash[:alert] = "Creating account failed. Try again. 1"
          end_session
          redirect_to new_account_path and return
        end
      else
        flash[:alert] = "Something went wrong. Try again. 1"
        end_session
        redirect_to new_account_path and return
      end

    elsif !@account.present?
      @account = Account.new(account_params)
      @account.verification_code = generate_verification_code
      if @account.save
       send_email(@account)
      else
        flash.now[:alert] = "Creating account failed. Try again. 2"
        render :new
      end
    else
      flash[:alert] = "Creating account failed. Try again. 3"
      end_session
      redirect_to new_account_path and return
    end
  end

  def verify_code  # handle the form submitted fron verify_code_page
    input_code = params[:verification_code]
    @account = Account.find_by(id: session[:create_account_id])

    unless @account
      end_session
      flash[:alert] = "Account not found"
      redirect_to new_account_path and return
    end


    if session[:create_account_verification_code_expires_at].blank? || session[:create_account_verification_code_expires_at] < Time.current
      end_session

      flash[:alert] = "Verification code has expired. Try again"
      redirect_to new_account_path and return
    elsif input_code == @account.verification_code && input_code == session[:create_account_verification_code]
      if @account.update(verified: true, verification_code: nil)
        end_session
        flash[:notice] = "Created account successfully."
        redirect_to root_path and return
      else
        flash[:notice] = "Something went wrong: #{@account.errors.full_messages.join(', ')}"
        Rails.logger.error "VERIFY CODE ERRORS: #{@account.errors.full_messages.join(', ')}"
        redirect_to new_account_path and return
      end
    elsif input_code != @account.verification_code
      flash[:notice] = "Verification code incorrect. Try again."
      redirect_to verify_code_page_accounts_path and return
    else
      flash[:notice] = "Something went wrong. Try again"
      end_session
      redirect_to new_account_path and return
    end 
  end

  def verify_code_page
    # shows a page for verification code input
  end

  def resend_verification_email
    @account = Account.find_by(id: session[:create_account_id])
    
    unless @account
      end_session
      flash[:alert] = "Session expired. Please start again."
      redirect_to new_account_path and return
    end

    @account.verification_code = generate_verification_code

    if @account.update_column(:verification_code, generate_verification_code)
      send_email(@account) and return
    else
      flash[:alert] = "Unable to resend verification code. Please contact support."
      redirect_to verify_code_page_accounts_path and return
    end
  end


  private

  def account_params
    params.require(:account).permit(:email, :password, :password_confirmation)
  end

  def generate_verification_code
    loop do
      code = rand(100000..999999).to_s
      return code unless Account.exists?(verification_code: code)
    end     
  end

  def send_email(account)
  generate_session(account)

  begin
    VerificationCodeMailer.verification_mail(account.email, account.verification_code).deliver_now
    flash[:alert] = "Verification Sent 1"
    redirect_to verify_code_page_accounts_path and return
  rescue => e 
    Rails.logger.error "EMAIL ERROR: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}"
    flash[:alert] = "Sending email failed: #{e.class} - #{e.message}"
    end_session
    redirect_to new_account_path and return
  end
end

  def generate_session(account)
    session[:create_account_id] = account.id
    session[:create_account_verification_code] = account.verification_code
    session[:create_account_verification_code_expires_at] = 300.seconds.from_now
  end

  def end_session
    session.delete(:create_account_id)
    session.delete(:create_account_verification_code)
    session.delete(:create_account_verification_code_expires_at)
  end

end
