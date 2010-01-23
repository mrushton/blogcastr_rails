class FacebookSessionsController < ApplicationController
  before_filter :set_facebook_session

  def create
    #TODO: responses in xml or json
    if facebook_session
      #TODO: exception handling
      #MVR - try and find the user otherwise create a new one
      @user = User.find_by_facebook_id(facebook_session.user.id)
      if @user.nil?
        #TODO: calling create does not work?
        @user = FacebookUser.new
        @user.facebook_id = facebook_session.user.id
        @user.save
      end
      sign_in(@user)
      render :nothing => true
      return
    else
      render :nothing => true, :status => :unauthorized
      return
    end
  end

  def destroy
    #MVR - clear the Facebook session information
    clear_facebook_session_information
    #MVR - clear Facebook cookies as well
    clear_fb_cookies!
    #MVR - clear private facebook avatar url if set
    session[:facebook_avatar_url] = nil
    #MVR - clear Blogcastr cookies
    sign_out
    flash_success_after_destroy
    render :nothing => true
  end

  private

  def sign_in(user)
    if user.instance_of?(BlogcastrUser)
      super
    else
      user.remember_me!
      #MVR - only sign in Facebook users for 1 day
      cookies[:remember_token] = {:value => user.remember_token, :expires => 1.day.from_now.utc}
      current_user = user
    end
  end
end
