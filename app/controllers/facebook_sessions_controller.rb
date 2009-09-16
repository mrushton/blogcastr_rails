class FacebookSessionsController < ApplicationController
  before_filter :set_facebook_session

  def create
    if facebook_session
        #TODO: exception handling
        @user = User.find_or_create_by_facebook_id(facebook_session.user.id)
        sign_in(@user)
        flash_success_after_create
        #MVR - redirect back or sign up 
        redirect_to_back_or_default(sign_up_url)
    else
      flash_failure_after_create
      render :template => 'sessions/new', :status => :unauthorized
    end
    render :nothing => true
  end

  def destroy
    #MVR - clear the Facebook session information
    clear_facebook_session_information
    #MVR - clear Facebook cookies as well
    clear_fb_cookies!
    #MVR - clear Blogcastr cookies
    sign_out
    flash_success_after_destroy
    redirect_to_back_or_default(url_after_destroy)
    render :nothing => true
  end

  private

  #MVR - only sign in Facebook users for 1 day
  def sign_in(user)
    if user
      user.remember_me!
      cookies[:remember_token] = {:value => user.remember_token, :expires => 1.day.from_now.utc}
      current_user = user
    end
  end

  def flash_failure_after_create
    flash.now[:failure] = translate(:bad_email_or_password,
      :scope   => [:clearance, :controllers, :sessions],
      :default => "Bad email or password.")
  end

  def flash_success_after_create
    flash[:success] = translate(:signed_in, :default =>  "Signed in.")
  end

  def flash_notice_after_create
    flash[:notice] = translate(:unconfirmed_email,
      :scope   => [:clearance, :controllers, :sessions],
      :default => "User has not confirmed email. " <<
                  "Confirmation email will be resent.")
  end
end
