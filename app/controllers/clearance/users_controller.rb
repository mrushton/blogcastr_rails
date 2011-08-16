class Clearance::UsersController < ApplicationController
  #MVR - needed to work around CSRF for REST api
  #TODO: add CSRF before filter for standard authentication only, other option is to modify Rails to bypass CSRF for certain user agents
  skip_before_filter :verify_authenticity_token, :only => [:create]
  before_filter :redirect_user, :only => [:new, :create], :if => :signed_in_as_blogcastr_user?
  filter_parameter_logging :password

  #MVR - This is needed to handle signing out from the Sign Up page
  def index
    redirect_to sign_up_path
  end

  def new
    @current_user = current_user
    @blogcastr_user = BlogcastrUser.new(params[:blogcastr_user])
    if !@current_user.nil? 
      @setting = @current_user.setting 
    end
    #MVR - check if username is valid if given
    if !@blogcastr_user.username.nil?
      if (@blogcastr_user.username.length < 4 || @blogcastr_user.username.length > 15 || @blogcastr_user.username !~ /^[\w_]*$/)
        @valid_username = false
      else
        #MVR - case insensitive
        user = BlogcastrUser.find(:first, :conditions => ["LOWER(username) = ?", @blogcastr_user.username.downcase])
        if user.nil?
          @valid_username = true
        else
          @valid_username = false
        end
      end
    end
    render :template => 'users/new', :layout => 'sign-up'
  end

  def create
    #AS DESIGNED: no need to get current user for REST api
    @current_user = current_user
    @blogcastr_user = BlogcastrUser.new(params[:blogcastr_user])
    @setting = Setting.new(params[:setting])
    #AS DESIGNED: only verify the recaptcha if not a Facebook/Twitter user or using the REST api 
    if @current_user.instance_of?(FacebookUser)
      @blogcastr_user.facebook_id = @current_user.facebook_id
      @blogcastr_user.facebook_access_token = @current_user.facebook_access_token
      @blogcastr_user.facebook_link = @current_user.facebook_link
    elsif @current_user.instance_of?(TwitterUser)
      @blogcastr_user.twitter_username = @current_user.twitter_username
      @blogcastr_user.twitter_id = @current_user.twitter_id
      @blogcastr_user.twitter_access_token = @current_user.twitter_access_token
      @blogcastr_user.twitter_token_secret = @current_user.twitter_token_secret
    elsif request.format.html? and !verify_recaptcha :private_key => "6Lc7igsAAAAAADE0g3jbIf8YWU6fpYJppSFa3iBt"
      @blogcastr_user.valid?
      #AS DESIGNED - valid? clears all errors so add it here 
      @blogcastr_user.errors.add_to_base("Humanness check failed")
      @setting.valid?
      render :template => 'users/new', :layout => 'sign-up' 
      return
    end
    #MVR - attempt to determine the time zone
    utc_offset = params[:utc_offset]
    if !utc_offset.nil?
      time_zone = nil
      #AS DESIGNED - only try to find US time zones
      ActiveSupport::TimeZone.us_zones.each do |zone|
        #MVR - calling zone.utc_offset ignores daylight savings time
        if zone.tzinfo.current_period.utc_total_offset == utc_offset.to_i * 60
          time_zone = zone
          break
        end
      end
      if !time_zone.nil?
        @setting.time_zone = time_zone.name
      else
        @setting.time_zone = "UTC" 
      end
    else
      @setting.time_zone = "UTC" 
    end
    #MVR - create authentication token for everyone
    @blogcastr_user.generate_authentication_token(params[:password])
    begin
      BlogcastrUser.transaction do
        @blogcastr_user.save!
        @setting.user_id = @blogcastr_user.id
        @setting.save!
      end
      begin
        #AS DESIGNED: create ejabberd account here since password gets encrypted
        #TODO: check return value
        thrift_client.create_user(@blogcastr_user.username, HOST, params[:blogcastr_user][:password])
        thrift_client_close
      rescue
        @blogcastr_user.errors.add_to_base "Unable to create ejabberd account"
        @setting.destroy
        @blogcastr_user.destroy
        respond_to do |format|
          format.html { render :template => 'users/new', :layout => 'sign-up' }
          format.xml { render :action => 'errors', :status => :unprocessable_entity }
        end
        return
      end
    rescue
      @setting.valid?
      respond_to do |format|
        format.html { render :template => 'users/new', :layout => 'sign-up' }
        format.xml { render :action => 'errors', :status => :unprocessable_entity }
      end
      return
    end
    if Rails.env.production?
      ClearanceMailer.deliver_confirmation @user
    else
      #AS DESIGNED: don't bother with email confirmation for sandbox
      @blogcastr_user.confirm_email!
    end 
    respond_to do |format|
      format.html {
        sign_in @blogcastr_user
        redirect_to home_path
      }
      format.xml { render :template => 'share/new/user', :locals => { :user => @blogcastr_user, :setting => @setting, :show_authentication_token => true } }
    end
  end

  def destroy
  end

  def valid
    if (!params[:blogcastr_user].nil?)
      @username = params[:blogcastr_user][:username]
    end
    #MVR - check if username is valid
    if (@username.nil? || @username.length < 4 || @username.length > 15 || @username !~ /^[0-9A-Za-z_]*$/)
      render :action => "invalid"
      return
    end
    #MVR - case insensitive
    @user = BlogcastrUser.find(:first, :conditions => ["LOWER(username) = ?", @username.downcase])
    #MVR - if user does not already exist it is valid
    if @user.nil?
      render :action => "valid"
    else
      render :action => "invalid"
    end
  end

  private

  def redirect_user
    redirect_back_or home_path
  end
end
