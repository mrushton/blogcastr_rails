class TwitterOauthController < ApplicationController
  before_filter :authenticate

  def init
    #MVR - get a request token from Twitter and redirect
    oauth_client = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
    begin
      #TODO: better way of setting domain?
      if Rails.env.production?
        oauth_client.set_callback_url("http://blogcastr.com" + twitter_oauth_callback_path)
      else
        oauth_client.set_callback_url("http://sandbox.blogcastr.com" + twitter_oauth_callback_path)
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
    user = current_user
    oauth_client = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
    oauth_client.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])
    session['rtoken'] = nil
    session['rsecret'] = nil
    twitter_user = Twitter::Base.new(oauth_client)
    twitter_profile = twitter_user.verify_credentials
    user.twitter_id = twitter_profile.id
    user.twitter_access_token = oauth_client.access_token.token
    user.twitter_token_secret = oauth_client.access_token.secret
    if !user.save
      render :action => "failure"
      return
    end
    #MVR - for settings page which will get reloaded
    flash[:settings_tab] = "connect"
    flash[:success] = "Changes saved!"
  end

  def destroy
    user = current_user
    user.twitter_id = nil
    if !user.save(false)
      render :action => "failure"
      return
    end
  end
end
