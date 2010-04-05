class TwitterSignInController < ApplicationController
  def init
    #MVR - get a request token from Twitter and redirect
    oauth_client = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET, :sign_in => true)
    begin
      #TODO: better way of setting domain?
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
    oauth_client.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])
    session['rtoken'] = nil
    session['rsecret'] = nil
    twitter_user = Twitter::Base.new(oauth_client)
    twitter_profile = twitter_user.verify_credentials
    #MVR - create or find the Twitter user and sign them in 
    user = TwitterUser.find_or_create_by_twitter_id(twitter_profile.id)
    user.twitter_access_token = oauth_client.access_token.token
    user.twitter_token_secret = oauth_client.access_token.secret
    if !user.save(false)
      render :action => "failure"
      return
    end
    sign_in(user)
  end

  def destroy
    #MVR - clear cookies
    sign_out
    redirect_to_back_or_default(sign_in_path)
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
