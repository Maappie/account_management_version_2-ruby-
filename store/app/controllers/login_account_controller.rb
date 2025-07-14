class LoginAccountController < ApplicationController
  before_action -> { require_session_key(:login_account_id) }, only: [:profile, :log_out, :admin_view]
  before_action :set_account, only: [:profile]

  def show
    redirect_to new_login_account_path and return
  end

  def new
    # shows the forms for login
  end

  def create
    account = Account.find_by(email: params[:email])

    if account.roles == "admin"
      generate_account_session(account)
      flash[:notice] = "Login as admin."
      redirect_to admin_view_login_account_index_path and return
    end

    if account.present?
      if account&.authenticate(params[:password])
        generate_account_session(account)
        flash[:notice] = "Login successfully."
        redirect_to profile_login_account_index_path and return
      else
        flash[:alert] = "Incorrect Password."
        render :new and return
      end
    else
      flash[:alert] = "Incorrect email."
      render :new and return
    end
  end

  def log_out
    flash[:notice] = "Account logged out."
    login_session_end
    redirect_to root_path and return
  end

  def profile
  end

  def admin_view
  end

  private

  def set_account
    @account = Account.find_by(id: session[:login_account_id])
    unless @account
      flash[:alert] = "You must be logged in to access this page."
      redirect_to new_login_account_path and return
    end
  end

  def generate_account_session(account)
    session[:login_account_id] = account.id
  end

  def login_session_end
    session[:login_account_id] = nil
  end
end
