class TwitterSessionsController < ApplicationController
  def init
    #MVR - get a request token from Twitter and redirect
    #MVR - sign in flow is slightly different
    if params[:sign_in] == true
      oauth_client = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET, :sign_in => true)
    else
      oauth_client = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
    end
    begin
      if Rails.env.production?
        oauth_client.set_callback_url("http://blogcastr.com" + twitter_oauth_callback_path)
      else
        oauth_client.set_callback_url("http://sandbox.blogcastr.com" + twitter_oauth_callback_path)
      end
    rescue 
      render :nothing => true
      return
    end
    session['rtoken'] = oauth_client.request_token.token
    session['rsecret'] = oauth_client.request_token.secret
    redirect_to oauth_client.request_token.authorize_url
  end

  def create
    oauth_client = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
    oauth_client.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])
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
    user = current_user
    if user.nil?
      #MVR - sign in with Twitter
      #MVR - find the user
      twitter_user = User.find_by_twitter_id(verify_credentials.id)
      if twitter_user.nil?
        #MVR - create a new user if they don't exist
        twitter_user = TwitterUser.new(:username => verify_credentials.screen_name, :twitter_id => verify_credentials.id, :twitter_access_token => oauth_client.access_token.token, :twitter_token_secret => oauth_client.access_token.secret)
        #TODO: set timezone info
        setting = Setting.new
        if (defined? verify_credentials.name)
          setting.full_name = verify_credentials.name
        end
        if (defined? verify_credentials.location)
          setting.location = verify_credentials.location
        end
        begin
          TwitterUser.transaction do
            #MVR - do not run validations
            twitter_user.save_without_validation!
            setting.user_id = twitter_user.id
            setting.save_without_validation!
          end
        rescue
          render :action => "failure"
          return
        end
      else
        #TODO: update info
        #MVR - update the access token and secret
        twitter_user.twitter_access_token = oauth_client.access_token.token
        twitter_user.twitter_token_secret = oauth_client.access_token.secret
        #MVR - do not run validations
        if !twitter_user.save(false)
          render :action => "failure"
          return
        end
      end
      sign_in(twitter_user)
    else
      #TODO: connect with Twitter
    end
  end

  def destroy
    user = current_user
    if user.instance_of?(BlogcastrUser)
      #MVR - clear twitter connection 
      user.twitter_id = nil 
      user.twitter_access_token = nil
      user.twitter_token_secret = nil
      #TODO: error handling
      user.save
    else
      #MVR - clear cookies
      sign_out
      redirect_to_back_or_default(url_after_destroy)
    end
  end

  private

  def sign_in(user)
    if user.instance_of?(BlogcastrUser)
      super
    else
      user.remember_me!
      #MVR - only sign in Twitter users for 1 day
      cookies[:remember_token] = {:value => user.remember_token, :expires => 1.day.from_now.utc}
      current_user = user
    end
  end
end
