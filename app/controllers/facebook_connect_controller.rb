class FacebookConnectController < ApplicationController
  before_filter :authenticate
  before_filter :set_facebook_session

  def create
    @user = current_user 
    if facebook_session
      #TODO: one query
      if !@user.update_attributes(params[:blogcastr_user])
        render :nothing => true, :status => :internal_server_error
      end
      @user.update_attribute(:facebook_id, facebook_session.user.id)
      if (params[:offline_access] == "1")
        @user.update_attribute(:facebook_session_key, facebook_session.session_key)
      end
      render :nothing => true
      #MVR - for settings page which will get reloaded
      flash[:settings_tab] = "connect"
      flash[:success] = "Changes saved!"
    else
      render :nothing => true, :status => :unauthorized
    end
  end

  def destroy
    user = current_user
    #MVR - clear the Facebook session information
    clear_facebook_session_information
    #MVR - clear Facebook cookies as well
    clear_fb_cookies!
    #MVR - clear private facebook avatar url if set
    session[:facebook_avatar_url] = nil
    #MVR - update user attributes
    user.facebook_id = nil
    if !user.save(false)
      render :action => "failure"
      return
    end
  end
end
