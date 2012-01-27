class UsersController < ApplicationController
  #MVR - needed to work around CSRF for REST api
  #TODO: add CSRF before filter for standard authentication only, other option is to modify Rails to bypass CSRF for certain user agents
  skip_before_filter :verify_authenticity_token

  def show
    if params[:authentication_token].nil?
      @current_user = current_user
    else 
      @current_user = rest_current_user
    end
    #MVR - find user by id 
    begin
      #TODO: for now only handle Blogcastr users
      @user = BlogcastrUser.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.xml { render :xml => "<errors><error>User #{params[:id]} does not exist</error></errors>", :status => :unprocessable_entity }
      end
      return
    end
    @setting = @user.setting
    if !@current_user.nil?
      @subscription = @current_user.subscriptions.find(:first, :conditions => { :subscribed_to => @user.id })
    end
    respond_to do |format|
      format.xml { render :template => 'share/new/user', :locals => { :current_user => @current_user, :user => @user, :setting => @setting, :subscription => @subscription } }
    end
  end
end
