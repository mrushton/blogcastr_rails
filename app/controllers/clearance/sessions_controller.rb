class Clearance::SessionsController < ApplicationController
  before_filter :insecure_redirect_to_home, :only => [:new, :create], :if => :signed_in_as_blogcastr_user?
  filter_parameter_logging :password

  def new
    render :template => 'sessions/new'
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
        insecure_redirect_back_or home_path
      else
        ClearanceMailer.deliver_confirmation(@user)
        flash[:info] = "A confirmation email has been resent. You must confirm your account before signing in." 
        insecure_redirect_back_insecure_or sign_in_path
      end
    end
  end

  def destroy
    sign_out
    redirect_back_or(sign_in_path)
  end

  private

  def insecure_redirect_to_home
    if Rails.env.production?
      redirect_to home_url
    else
      redirect_to home_path
    end
  end

  #MVR - handle https in production
  def insecure_redirect_back_or(default)
    if Rails.env.production?
      url = return_to || default
      if url =~ /\//
        url = "http://blogcastr" + url
      end
      redirect_to url
      clear_return_to
    else
      redirect_to(return_to || default)
      clear_return_to
    end
  end
end
