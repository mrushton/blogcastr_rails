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
      #MVR - create setting
      @setting = Setting.create(:user_id => @user.id)
      #MVR - create blog
      @blogcast = Blogcast.create(:user_id => @user.id)
      begin
        #AS DESIGNED: create ejabberd account here since password gets encrypted
        thrift_client.create_user(@user.name, params[:blogcastr_user][:password])
        #AS DESIGNED: one node and muc per user
        thrift_client.create_pubsub_node(@user.name, "/home/blogcastr.com/" + @user.name)
        thrift_client.create_pubsub_node(@user.name, "/home/blogcastr.com/" + @user.name + "/blog")
        thrift_client.create_muc_room(@user.name, @user.name + "." + "blog", @user.name + "'s blogcast", "")
        thrift_client_close
      rescue
        @user.destroy
        @setting.destroy
        @blogcast.destroy
        flash[:notice] = "Error: Unable to create ejabberd account"
        render :template => 'users/new'
        return
      end
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
    redirect_to dashboard_url
  end
end
