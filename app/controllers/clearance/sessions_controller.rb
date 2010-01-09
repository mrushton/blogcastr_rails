class Clearance::SessionsController < ApplicationController
  #actually do not want to do this
  before_filter :redirect_to_dashboard, :only => [:new, :create], :if => :signed_in_as_blogcastr_user?
  protect_from_forgery :except => :create
  filter_parameter_logging :password

  def new
    render :template => 'sessions/new'
  end

  def create
    @session = params[:session]
    if @session.nil?
      flash_failure_after_create
      render :template => 'sessions/new', :status => :unauthorized
    end
    @user = ::BlogcastrUser.authenticate(@session[:username], @session[:password])
    if @user.nil?
      flash_failure_after_create
      render :template => 'sessions/new', :status => :unauthorized
    else
      if @user.email_confirmed?
        sign_in(@user)
        flash_success_after_create
        redirect_back_or(url_after_create)
      else
        ::ClearanceMailer.deliver_confirmation(@user)
        flash_notice_after_create
        redirect_to(new_session_path)
      end
    end
  end

  def destroy
    sign_out
    flash_success_after_destroy
    redirect_to(url_after_destroy)
  end

  private

  def flash_failure_after_create
    flash.now[:failure] = translate(:bad_email_or_password,
      :scope   => [:clearance, :controllers, :sessions],
      :default => "Bad email or password.")
  end

  def flash_success_after_create
    flash[:success] = translate(:signed_in, :default =>  "Signed in.")
  end

  def flash_notice_after_create
    flash[:notice] = translate(:unconfirmed_email,
      :scope   => [:clearance, :controllers, :sessions],
      :default => "User has not confirmed email. " <<
                  "Confirmation email will be resent.")
  end

  def url_after_create
    home_path
  end

  def flash_success_after_destroy
    flash[:success] = translate(:signed_out, :default =>  "Signed out.")
  end

  def url_after_destroy
    new_session_path
  end

  def redirect_to_dashboard
    redirect_to :controller => "/dashboard"
  end
end
