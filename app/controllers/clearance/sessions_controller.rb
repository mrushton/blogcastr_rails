class Clearance::SessionsController < ApplicationController
  before_filter :redirect_user, :only => [:new, :create], :if => :signed_in?
  filter_parameter_logging :password

  def new
    render :template => 'sessions/new', :layout => 'sign-in'
    return
  end

  def create
    @user = BlogcastrUser.authenticate(params[:username], params[:password])
    if @user.nil?
      flash[:error] = "Oops! Invalid username/email address or password."
      redirect_to sign_in_path
    else
      #MVR - no longer require email confirmation
      sign_in(@user)
      redirect_back_or home_path
    end
  end

  def destroy
    sign_out
    redirect_back_or sign_in_path
  end

  private

  #MVR - this redirects users that are already signed in
  def redirect_user
    if signed_in_as_blogcastr_user?
      redirect_to home_path
    else
      redirect_to sign_up_path
    end
  end
end
