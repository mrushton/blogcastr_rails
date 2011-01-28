class Clearance::SessionsController < ApplicationController
  before_filter :secure_redirect_to_home, :only => [:new, :create], :if => :signed_in_as_blogcastr_user?
  filter_parameter_logging :password

  def new
    render :template => 'sessions/new', :layout => 'sign-in'
  end

  def create
    @user = BlogcastrUser.authenticate(params[:username], params[:password])
    if @user.nil?
      flash[:error] = "Oops! Invalid username/email address or password."
      redirect_to sign_in_path
    else
      #MVR - redeliver email if not confirmed 
      if @user.email_confirmed?
        sign_in(@user)
        secure_redirect_back_or home_path
      else
        ClearanceMailer.deliver_confirmation(@user)
        flash[:info] = "A confirmation email has been resent. You must confirm your account before signing in." 
        secure_redirect_back_or sign_in_path
      end
    end
  end

  def destroy
    sign_out
    redirect_back_or sign_in_path
  end
end
