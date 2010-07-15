class Clearance::SessionsController < ApplicationController
  before_filter :redirect_to_home, :only => [:new, :create], :if => :signed_in_as_blogcastr_user?
  filter_parameter_logging :password

  def new
    #MVR - use https in prodcution
    if Rails.env.production?
      @session_url = "https://blogcastr.com/session"
    else
      @session_url = session_path 
    end
    render :template => 'sessions/new'
  end

  def create
    @user = BlogcastrUser.authenticate(params[:username], params[:password])
    if @user.nil?
      flash[:error] = "Oops! Invalid username/email address or password."
      redirect_to sign_in_path
    else
      if @user.email_confirmed?
        sign_in(@user)
        if Rails.env.production?
          redirect_back_or home_url
        else
          redirect_back_or home_path
        end
      else
        ClearanceMailer.deliver_confirmation(@user)
        flash[:info] = "A confirmation email has been resent. You must confirm your account before signing in." 
        if Rails.env.production?
          redirect_back_or sign_in_url
        else
          redirect_back_or sign_in_path
        end
      end
    end
  end

  def destroy
    sign_out
    redirect_back_or(sign_in_path)
  end

  private

  def redirect_to_home
    redirect_to :controller => "/home"
  end
end
