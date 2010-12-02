class FacebookSignInController < ApplicationController
  include HTTParty
  base_uri 'https://graph.facebook.com'
  format :json

  def create
@error_reason = "1"
    if !params[:error_reason].blank?
      @error_reason = params[:error_reason]
      render :action => "error"
      return
    end
@error_reason = "2"
    if params[:code].blank?
      render :action => "error"
      return
    end
@error_reason = "/oauth/access_token?client_id=" + FACEBOOK_APP_ID + "&redirect_uri=" + HOST + facebook_login_redirect_path + "&client_secret=" + FACEBOOK_APP_SECRET + "code=" + params[:code] 
    #MVR - get access token with code
    begin
      @access_token = get("/oauth/access_token?client_id=" + FACEBOOK_APP_ID + "&redirect_uri=" + HOST + facebook_login_redirect_path + "&client_secret=" + FACEBOOK_APP_SECRET + "code=" + params[:code])
    rescue
      render :action => "error"
      return
    end
  end

  def destroy
  end
end
