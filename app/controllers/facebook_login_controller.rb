class FacebookLoginController < ApplicationController
  include HTTParty
  include HTTPRedirects
  #TODO: add CSRF before filter for standard authentication only, other option is to modify Rails to bypass CSRF for certain user agents
  skip_before_filter :verify_authenticity_token
  before_filter :only => [ "connect", "disconnect" ] do |controller|
    #AS DESIGNED: this only works with the REST api 
    controller.rest_authenticate
  end
  base_uri "https://graph.facebook.com"

  def create
    if !params[:error_reason].blank?
      @error_reason = params[:error_reason]
      if @error_reason == "user_denied"
        render :action => "cancel"
        return
      else
        render :action => "error"
        return
      end
    end
    if params[:code].blank?
      render :action => "error"
      return
    end
    begin
      #MVR - get access token with code, redirect uri depends on protocol
      if request.ssl?
        oauth_access_token = self.class.get("/oauth/access_token", :query => { :client_id => FACEBOOK_APP_ID, :redirect_uri => "https://" + HOST + facebook_login_redirect_path, :client_secret => FACEBOOK_APP_SECRET, :code => params[:code] })
      else
        oauth_access_token = self.class.get("/oauth/access_token", :query => { :client_id => FACEBOOK_APP_ID, :redirect_uri => "http://" + HOST + facebook_login_redirect_path, :client_secret => FACEBOOK_APP_SECRET, :code => params[:code] })
      end
      access_token = CGI.parse(oauth_access_token)["access_token"][0]
      #MVR - get user info
      me = self.class.get("/me", :query => { :access_token => access_token })
    rescue
      render :action => "error"
      return
    end
    #MVR - find Blogcastr user first
    user = BlogcastrUser.find_by_facebook_id(me["id"])
    if user.nil?
      #MVR - find Facebook user first
      user = FacebookUser.find_by_facebook_id(me["id"])
    end
    if user.nil?
      #MVR - create a new user if they don't exist
      user = FacebookUser.new
      user.facebook_access_token = access_token
      user.facebook_id = me["id"]
      user.facebook_full_name = me["name"]
      user.facebook_link = me["link"]
      #TODO: set other info
      setting = Setting.new
      setting.full_name = me["name"] 
      #MVR - get avatar
      url = URI.parse("http://graph.facebook.com/" + me["id"] + "/picture?type=square")
      begin
        redirect_follower = RedirectFollower.new("http://graph.facebook.com/" + me["id"] + "/picture?type=square", 2).resolve
        avatar_name = File.basename(redirect_follower.url)
        avatar = ActionController::UploadedTempfile.new(avatar_name)
        avatar.binmode
        avatar.write(redirect_follower.body)
        avatar.original_path = avatar_name
        avatar.content_type = redirect_follower.response["Content-Type"]
        avatar.rewind
      rescue TimeoutError
        render :action => "error"
        return
      rescue TooManyRedirects 
        render :action => "error"
        return
      end
      setting.avatar = avatar
      avatar.close!
      begin
        FacebookUser.transaction do
          #MVR - do not run validations
          user.save_without_validation!
          setting.user_id = user.id
          setting.save_without_validation!
        end
      rescue
        render :action => "error"
        return
      end
    else
      #TODO: update info if Facebook user
      #MVR - update the access token and secret
      user.facebook_access_token = access_token
      #MVR - do not run validations
      if !user.save(false)
        render :action => "error"
        return
      end
    end
    sign_in(user)
  end

  def destroy
    #MVR - clear cookies
    sign_out
    redirect_to :back
  end

  def connect
    @current_user = rest_current_user
    access_token = params[:blogcastr_user][:facebook_access_token]
    begin
      expires_at = Time.iso8601(params[:blogcastr_user][:facebook_expires_at])
    rescue ArgumentError
      expires_at = nil
    end
    if (access_token.blank? || expires_at.blank?)
      respond_to do |format|
        format.xml { head :unprocessable_entity }
      end
      return
    end
    begin
      #MVR - get user info
      me = self.class.get("/me", :query => { :access_token => access_token })
      permissions = self.class.get("/me/permissions", :query => { :access_token => access_token })
    rescue
      respond_to do |format|
        format.xml { head :internal_server_error }
      end
      return
    end
    #AS DESIGNED: currently you can use Facebook to sign in so you can only connect one account
    facebook_id = me["id"]
    user = BlogcastrUser.find_by_facebook_id(facebook_id, :conditions => ["id != ?", @current_user.id])
    if !user.nil?
      @current_user.errors.add_to_base("Facebook account is connected to another Blogcastr account")
      respond_to do |format|
        format.xml { render :action => 'errors', :status => :unprocessable_entity }
      end
      return
    end
    @current_user.facebook_access_token = access_token
    @current_user.facebook_expires_at = expires_at
    @current_user.facebook_id = facebook_id 
    @current_user.facebook_full_name = me["name"]
    @current_user.facebook_link = me["link"]
    @current_user.has_facebook_publish_stream = false 
    if !permissions["data"].kind_of?(Array)
      respond_to do |format|
        format.xml { head :internal_server_error }
      end
      return
    end
    #MVR - check permissions for publish stream
    permissions["data"].each { |permission|
      if permission["publish_stream"] == 1
        @current_user.has_facebook_publish_stream = true
      end
    }
    if @current_user.save
      respond_to do |format|
        format.xml { render :template => 'share/new/user', :locals => { :current_user => @current_user, :user => @current_user, :setting => @current_user.setting } }
      end
    else
      respond_to do |format|
        format.xml { render :action => 'errors', :status => :unprocessable_entity }
      end
    end
  end

  def extend
    @current_user = rest_current_user
    access_token = params[:blogcastr_user][:facebook_access_token]
    begin
      expires_at = Time.iso8601(params[:blogcastr_user][:facebook_expires_at])
    rescue ArgumentError
      expires_at = nil
    end
    #MVR - access token must already be connented
    if (access_token.blank? || expires_at.blank? || access_token != @current_user.facebook_access_token)
      respond_to do |format|
        format.xml { head :unprocessable_entity }
      end
      return
    end
    @current_user.facebook_expires_at = expires_at
    if @current_user.save
      respond_to do |format|
        format.xml { head :ok }
      end
    else
      respond_to do |format|
        format.xml { render :action => 'errors', :status => :unprocessable_entity }
      end
    end
  end
 
  def invalidate 
    @current_user = rest_current_user
    @current_user.facebook_access_token = nil 
    @current_user.facebook_expires_at = nil 
    @current_user.has_facebook_publish_stream = false 
    if @current_user.save
      respond_to do |format|
        format.xml { head :ok }
      end
    else
      respond_to do |format|
        format.xml { render :action => 'errors', :status => :unprocessable_entity }
      end
    end
  end

  def disconnect
    @current_user = rest_current_user
    @current_user.facebook_access_token = nil 
    @current_user.facebook_expires_at = nil 
    @current_user.facebook_id = nil 
    @current_user.facebook_full_name = nil 
    @current_user.facebook_link = nil 
    @current_user.has_facebook_publish_stream = false 
    if @current_user.save
      respond_to do |format|
        format.xml { head :ok }
      end
    else
      respond_to do |format|
        format.xml { render :action => 'errors', :status => :unprocessable_entity }
      end
    end
  end

  private

  def sign_in(user)
    if user.instance_of?(BlogcastrUser)
      super
    else
      user.remember_me!
      #MVR - only sign in Facebook users for 1 day
      cookies[:remember_token] = { :value => user.remember_token, :expires => 1.day.from_now.utc }
      current_user = user
    end
  end
end
