class TwitterSignInController < ApplicationController
  def init
    #MVR - get a request token from Twitter and redirect
    oauth_client = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET, :sign_in => true)
    begin
      if Rails.env.production?
        oauth_client.set_callback_url("http://blogcastr.com" + twitter_sign_in_callback_path)
      else
        oauth_client.set_callback_url("http://sandbox.blogcastr.com" + twitter_sign_in_callback_path)
      end
    rescue 
      render :action => "failure"
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
      render :action => "failure"
      return
    end
    session['rtoken'] = nil
    session['rsecret'] = nil
    client = Twitter::Base.new(oauth_client)
    #MVR - verify credentials returns info about the authenticated user 
    begin
      verify_credentials = client.verify_credentials
    rescue
      render :action => "failure"
      return
    end
    #MVR - find the Twitter user
    user = User.find_by_twitter_id(verify_credentials.id)
    if user.nil?
      #MVR - create a new user if they don't exist
      user = TwitterUser.new
      user.username = verify_credentials.screen_name
      user.twitter_id = verify_credentials.id
      user.twitter_access_token = oauth_client.access_token.token
      user.twitter_token_secret = oauth_client.access_token.secret
      #TODO: set timezone info
      setting = Setting.new
      if (defined? verify_credentials.name)
        setting.full_name = verify_credentials.name
      end
      if (defined? verify_credentials.location)
        setting.location = verify_credentials.location
      end
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
        render :action => "failure"
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
        render :action => "failure"
        return
      end
    else
      #TODO: update info if Twitter user
      #MVR - update the access token and secret
      user.twitter_access_token = oauth_client.access_token.token
      user.twitter_token_secret = oauth_client.access_token.secret
      #MVR - do not run validations
      if !user.save(false)
        render :action => "failure"
        return
      end
    end
    sign_in(user)
  end

  def destroy
    #MVR - clear cookies
    sign_out
    redirect_back_or sign_in_path
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
