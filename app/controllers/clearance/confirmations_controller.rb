class Clearance::ConfirmationsController < ApplicationController
  before_filter :redirect_signed_in_confirmed_user,  :only => [:new, :create]
  before_filter :redirect_signed_out_confirmed_user, :only => [:new, :create]
  before_filter :forbid_missing_token,               :only => [:new, :create]
  before_filter :forbid_non_existent_user,           :only => [:new, :create]

  filter_parameter_logging :token

  def new
    create
  end

  def create
    @user = ::BlogcastrUser.find_by_id_and_confirmation_token(params[:user_id], params[:token])
    sign_in(@user)
    #MVR - create setting
    @setting = Setting.create(:user_id => @user.id)
    #MVR - create blog
    @blogcast = Blogcast.create(:user_id => @user.id)
    #MVR - create ejabberd account
    begin
      #thrift_client.create_user(@user.login,params[:user][:password])
      #AS DESIGNED: one node and muc per user
      #thrift_client.create_pubsub_node(@user.login, "/home/blogcastr.com/" + @user.login)
      #thrift_client.create_pubsub_node(@user.login, "/home/blogcastr.com/" + @user.login + "/blog")
      #thrift_client.create_muc_room(@user.login, @user.login + "." + "blog", @user.login + "'s blogcast", "")
      #thrift_client_close
    rescue
      @setting.destroy
      @blogcast.destroy
      flash[:notice] = "Error: Unable to create ejabberd account"
      #TODO: how to handle this?
      render :action => :new
      return
    end
    @user.confirm_email!
    flash_success_after_create
    redirect_to(url_after_create)
  end

  private

  def redirect_signed_in_confirmed_user
    user = ::BlogcastrUser.find_by_id(params[:user_id])
    if user && user.email_confirmed? && current_user == user
      flash_success_after_create
      redirect_to(url_after_create)
    end
  end

  def redirect_signed_out_confirmed_user
    user = ::BlogcastrUser.find_by_id(params[:user_id])
    #MVR - you may not be signed as a blogcastr user
    if user && user.email_confirmed? && !signed_in_as_blogcastr_user?
      flash_already_confirmed
      redirect_to(url_already_confirmed)
    end
  end

  def forbid_missing_token
    if params[:token].blank?
      raise ActionController::Forbidden, "missing token"
    end
  end

  def forbid_non_existent_user
    unless ::BlogcastrUser.find_by_id_and_confirmation_token(
                  params[:user_id], params[:token])
      raise ActionController::Forbidden, "non-existent user"
    end
  end

  def flash_success_after_create
    flash[:success] = translate(:confirmed_email,
      :scope   => [:clearance, :controllers, :confirmations],
      :default => "Confirmed email and signed in.")
  end

  def flash_already_confirmed
    flash[:success] = translate(:already_confirmed_email,
      :scope   => [:clearance, :controllers, :confirmations],
      :default => "Already confirmed email. Please sign in.")
  end

  def url_after_create
    url_for :controller => "/dashboard"
  end

  def url_already_confirmed
    sign_in_url
  end
end
