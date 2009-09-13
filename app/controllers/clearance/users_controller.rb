class Clearance::UsersController < ApplicationController
  #MVR - redirect to dashboard
  before_filter :redirect_to_dashboard, :only => [:new, :create], :if => :signed_in_as_blogcastr_user?
  filter_parameter_logging :password

  def new
    @user = ::BlogcastrUser.new(params[:blogcastr_user])
    render :template => 'users/new'
  end

  def create
    @user = ::BlogcastrUser.new params[:blogcastr_user]
    if @user.save
      ::ClearanceMailer.deliver_confirmation @user
      flash_notice_after_create
      redirect_to(url_after_create)
    else
      render :template => 'users/new'
    end
  end

  private

  def flash_notice_after_create
    flash[:notice] = translate(:deliver_confirmation,
      :scope   => [:clearance, :controllers, :users],
      :default => "You will receive an email within the next few minutes. " <<
                  "It contains instructions for confirming your account.")
  end

  def url_after_create
    new_session_url
  end

  def redirect_to_dashboard
    redirect_to :controller => "/dashboard"
  end
end
