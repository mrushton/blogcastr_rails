class Clearance::PasswordsController < ApplicationController
  unloadable

  before_filter :forbid_missing_token,     :only => [:edit, :update]
  before_filter :forbid_non_existent_user, :only => [:edit, :update]
  filter_parameter_logging :password, :password_confirmation

  def new
    render :template => 'passwords/new', :layout => 'forgot-password'
  end

  def create
    if user = ::User.find_by_email(params[:password][:email])
      user.forgot_password!
      ::ClearanceMailer.deliver_change_password user
      flash[:info] = "You have been sent an email with instructions on how to reset your password."
      redirect_to new_session_url
    else
      flash.now[:error] = "Oops! Could not find email address." 
      render :template => 'passwords/new', :layout => 'forgot-password'
    end
  end

  def edit
    @user = ::User.find_by_id_and_confirmation_token(
                   params[:user_id], params[:token])
    render :template => 'passwords/edit', :layout => 'change-password'
  end

  def update
    @user = ::User.find_by_id_and_confirmation_token(
                   params[:user_id], params[:token])

    if @user.update_password(params[:user][:password],
                             params[:user][:password_confirmation])
      @user.confirm_email!
      sign_in(@user)
      flash[:success] = "Password changed"
      redirect_to home_path
    else
      render :template => 'passwords/edit', :layout => 'change-password'
    end
  end

  private

  def forbid_missing_token
    if params[:token].blank?
      raise ActionController::Forbidden, "missing token"
    end
  end

  def forbid_non_existent_user
    unless ::User.find_by_id_and_confirmation_token(
                  params[:user_id], params[:token])
      raise ActionController::Forbidden, "non-existent user"
    end
  end
end
