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
      #TODO: better way of setting domain?
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
    twitter_user = Twitter::Base.new(oauth_client)
    twitter_profile = twitter_user.verify_credentials
    #MVR - a user may be connecting their Twitter accounts and already logged in
    user = current_user
    if user.nil?
      user = TwitterUser.find_or_create_by_twitter_id(twitter_profile.id)
      sign_in(user)
    else
      user.twitter_id = twitter_profile.id
    end
    user.twitter_access_token = oauth_client.access_token.token
    user.twitter_token_secret = oauth_client.access_token.secret
    user.save
  end

  def destroy
    if params[:sign_out] == true
      #MVR - clear Blogcastr cookies
      sign_out
      redirect_to_back_or_default(url_after_destroy)
    else
      user = current_user
      user.twitter_id = nil 
      user.save
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
