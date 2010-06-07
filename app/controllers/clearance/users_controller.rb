class Clearance::UsersController < ApplicationController
  before_filter :redirect_to_home, :only => [:new, :create], :if => :signed_in_as_blogcastr_user?
  filter_parameter_logging :password

  def new
    @blogcastr_user = BlogcastrUser.new(params[:blogcastr_user])
    render :template => 'users/new', :layout => true
  end

  def create
    @blogcastr_user = BlogcastrUser.new(params[:blogcastr_user])
    #MVR - make username lowercase
    #TODO: could add a database field to support multi-case usernames if desired
    #@blogcastr_user.username = @blogcastr_user.username.downcase
    #MVR - create setting
    @setting = Setting.new(params[:setting])
    #MVR - verify the recaptcha
    if !verify_recaptcha :private_key => "6Lc7igsAAAAAADE0g3jbIf8YWU6fpYJppSFa3iBt"
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
      #AS DESIGNED - only try to find US time zones
      time_zone = nil
      ActiveSupport::TimeZone.us_zones.each do |zone|
        #MVR - calling zone.utc_offset ignores daylight savings time
        if zone.tzinfo.current_period.utc_total_offset == utc_offset.to_i*60
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
      redirect_to sign_in_path
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
    if (@username.nil? || @username.length < 4 || @username.length > 15 || @username !~ /^[\w_]*$/)
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

  def redirect_to_home
    redirect_to :controller => "/home"
  end
end
