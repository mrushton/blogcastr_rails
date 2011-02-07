class Clearance::UsersController < ApplicationController
  before_filter :redirect_user, :only => [:new, :create], :if => :signed_in_as_blogcastr_user?
  filter_parameter_logging :password

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
    @current_user = current_user
    @blogcastr_user = BlogcastrUser.new(params[:blogcastr_user])
    @setting = Setting.new(params[:setting])
    #AS DESIGNED: only verify the recaptcha if not a Facebook or Twitter user
    if @current_user.instance_of?(FacebookUser)
      @blogcastr_user.facebook_id = @current_user.facebook_id
      @blogcastr_user.facebook_access_token = @current_user.facebook_access_token
      @blogcastr_user.facebook_link = @current_user.facebook_link
    elsif @current_user.instance_of?(TwitterUser)
      @blogcastr_user.twitter_username = @current_user.twitter_username
      @blogcastr_user.twitter_id = @current_user.twitter_id
      @blogcastr_user.twitter_access_token = @current_user.twitter_access_token
      @blogcastr_user.twitter_token_secret = @current_user.twitter_token_secret
    elsif !verify_recaptcha :private_key => "6Lc7igsAAAAAADE0g3jbIf8YWU6fpYJppSFa3iBt"
      @blogcastr_user.valid?
      #AS DESIGNED - valid? clears all errors so add it here 
      @blogcastr_user.errors.add_to_base("Humanness check failed")
      @setting.valid?
      render :template => 'users/new'
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
        render :template => 'users/new'
        return
      end
    rescue
      @setting.valid?
      render :template => 'users/new'
      return
    end
    if Rails.env.production?
      ClearanceMailer.deliver_confirmation @blogcastr_user
      #TODO: do we want a separate confirmation page?
      flash[:info] = "Welcome! A confirmation message has been sent to your email address."
      redirect_to sign_in_url
    else
      #AS DESIGNED: don't bother with email confirmation for sandbox
      @blogcastr_user.confirm_email!
      sign_in @blogcastr_user
      redirect_to home_path
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
