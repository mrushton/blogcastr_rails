class TwitterSignInController < ApplicationController
  #TODO: add CSRF before filter for standard authentication only, other option is to modify Rails to bypass CSRF for certain user agents
  skip_before_filter :verify_authenticity_token
  before_filter :only => [ "connect", "disconnect" ] do |controller|
    #AS DESIGNED: this only works with the REST api 
    controller.rest_authenticate
  end

  def init
    #MVR - get a request token from Twitter and redirect
    oauth_client = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET, :sign_in => true)
    begin
      if Rails.env.production?
        #TODO: currently an Apache bug exists where environment variables are not getting set and request.ssl? always returns false
        oauth_client.set_callback_url(twitter_sign_in_callback_url)
      else
        oauth_client.set_callback_url("http://sandbox.blogcastr.com" + twitter_sign_in_callback_path)
      end
    rescue 
      render :action => "error"
      return
    end
    session['rtoken'] = oauth_client.request_token.token
    session['rsecret'] = oauth_client.request_token.secret
    redirect_to oauth_client.request_token.authorize_url
  end

  def create
    oauth_client = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
    begin
      oauth_client.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])
    rescue
      render :action => "error"
      return
    end
    session['rtoken'] = nil
    session['rsecret'] = nil
    client = Twitter::Base.new(oauth_client)
    #MVR - verify credentials returns info about the authenticated user 
    begin
      verify_credentials = client.verify_credentials
    rescue
      render :action => "error"
      return
    end
    #MVR - find Blogcastr user first
    user = BlogcastrUser.find_by_twitter_id(verify_credentials.id)
    if user.nil?
      #MVR - find Twitter user
      user = TwitterUser.find_by_twitter_id(verify_credentials.id)
    end
    if user.nil?
      #MVR - create a new user if they don't exist
      user = TwitterUser.new
      user.username = verify_credentials.screen_name
      user.twitter_username = verify_credentials.screen_name
      user.twitter_id = verify_credentials.id
      user.twitter_access_token = oauth_client.access_token.token
      user.twitter_token_secret = oauth_client.access_token.secret
      #TODO: set timezone info
      setting = Setting.new
      #AS DESIGNED: set to nil if undefined
      setting.full_name = verify_credentials.name
      setting.location = verify_credentials.location
      #MVR - get avatar
      url = URI.parse(verify_credentials.profile_image_url)
      avatar_name = File.basename(url.path)
      avatar = nil
      begin
        timeout(10) do
          Net::HTTP.start(url.host, url.port) do |http|
            resp = http.get(url.path)
            avatar = ActionController::UploadedTempfile.new(avatar_name)
            avatar.binmode
            avatar.write(resp.body)
            avatar.original_path = avatar_name
            avatar.content_type = resp["Content-Type"]
            avatar.rewind
          end
        end
      rescue TimeoutError
        render :action => "error"
        return
      end
      setting.avatar = avatar
      avatar.close!
      begin
        TwitterUser.transaction do
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
      #TODO: update info if Twitter user
      #MVR - update the access token and secret
      user.twitter_access_token = oauth_client.access_token.token
      user.twitter_token_secret = oauth_client.access_token.secret
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
    access_token = params[:blogcastr_user][:twitter_access_token]
    token_secret = params[:blogcastr_user][:twitter_token_secret]
    if (access_token.blank? || token_secret.blank?)
      respond_to do |format|
        format.xml { head :unprocessable_entity }
      end
      return
    end
    oauth_client = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
    oauth_client.authorize_from_access(access_token, token_secret)
    #MVR - get Twitter username and id
    client = Twitter::Base.new(oauth_client)
    #MVR - verify credentials returns info about the authenticated user 
    begin
      verify_credentials = client.verify_credentials
    rescue
      respond_to do |format|
        format.xml { head :internal_server_error }
      end
      return
    end
    #MVR - make sure Twitter account is not taken by someone else
    twitter_username = verify_credentials.screen_name
    #AS DESIGNED: currently you can use Twitter to sign in so you can only connect one account
    user = BlogcastrUser.find_by_twitter_username(twitter_username, :conditions => ["id != ?", @current_user.id])
    if !user.nil?
      @current_user.errors.add_to_base("Twitter account is connected to another Blogcastr account")
      respond_to do |format|
        format.xml { render :action => 'errors', :status => :unprocessable_entity }
      end
      return
    end
    @current_user.twitter_access_token = access_token
    @current_user.twitter_token_secret = token_secret
    @current_user.twitter_username =twitter_username 
    @current_user.twitter_id = verify_credentials.id 
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
    @current_user.twitter_access_token = nil 
    @current_user.twitter_token_secret = nil 
    @current_user.twitter_username = nil 
    @current_user.twitter_id = nil 
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
      #MVR - only sign in Twitter users for 1 day
      cookies[:remember_token] = { :value => user.remember_token, :expires => 1.day.from_now.utc }
      current_user = user
    end
  end
end
