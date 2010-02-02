class SmsUserNotificationsController < ApplicationController
  def create
    @profile_user = User.find_by_username(params[:username])
    if @profile_user.nil?
      @error = "Unable to add sms notifications for #{params[:username]}. User does not exist."
      render :action => "error"
      return
    end
    user = current_user
    #MVR - make sure user is signed in
    if user.nil?
      @error = "Unable to add sms notifications for #{@profile_user.name}. You are not signed in."
      render :action => "error"
      return
    end
    if user.id == @profile_user.id
      @error = "Unable to add sms notifications for #{@profile_user.username}. You can not be notified about yourself."
      render :action => "error"
      return
    end
    #MVR - do not allow the same notification multiple times
    @sms_user_notification = SmsUserNotification.find(:first, :conditions => {:user_id => user.id, :notifying_about => @profile_user.id})
    if !@sms_user_notification.nil?
      @error = "Unable to add sms notifications for #{@profile_user.username}. You were already being notified."
      render :action => "error"
      return
    end
    #MVR - add to database
    @sms_user_notification = SmsUserNotification.new
    @sms_user_notification.user_id = user.id
    @sms_user_notification.notifying_about = @profile_user.id
    @sms_user_notification.save
    #TODO: handle error
    @profile_username_possesive = @profile_user.username + (@profile_user.username =~ /.*s$/ ? "'":"'s")
  end

  def destroy
    @profile_user = User.find_by_username(params[:username])
    if @profile_user.nil?
      @error = "Unable to delete sms notifications for #{params[:username]}. User does not exist."
      render :action => "error"
      return
    end
    user = current_user
    #MVR - make sure user is signed in
    if user.nil?
      @error = "Unable to destroy sms notifications for #{@profile_user.username}. You are not signed in."
      render :action => "error"
      return
    end
    #MVR - delete from to database
    @sms_user_notification = SmsUserNotification.find(:first, :conditions => {:user_id => user.id, :notifying_about => @profile_user.id})
    if !@sms_user_notification.nil?
      @sms_user_notification.destroy
    end
    #TODO: handle error
    @profile_username_possesive = @profile_user.username + (@profile_user.username =~ /.*s$/ ? "'":"'s")
  end
end
