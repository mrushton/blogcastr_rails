class FacebookLoginController < ApplicationController
  include HTTParty
  include HTTPRedirects
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
      user.facebook_id = me["id"]
      user.facebook_access_token = access_token
      user.facebook_link = me["link"]
      #TODO: set other info
      setting = Setting.new
      setting.full_name = me["name"] 
      #MVR - get avatar
      url = URI.parse("http://graph.facebook.com/" + me["id"] + "/picture?type=square")
      avatar_name = File.basename(url.path)
      avatar = nil
      begin
        redirect_follower = RedirectFollower.new("http://graph.facebook.com/" + me["id"] + "/picture?type=square", 2).resolve
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
