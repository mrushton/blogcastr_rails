class SmsBlogcastNotificationsController < ApplicationController
  def create
    @blogcast = Blogcast.find(params[:blogcast_id])
    if @blogcast.nil?
      @error = "Unable to add sms notification for blogcast. Blogcast does not exist."
      render :action => "error"
      return
    end
    user = current_user
    #MVR - make sure user is signed in
    if user.nil?
      @error = "Unable to add sms notification for \"#{@blogcast.title}\". You are not signed in."
      render :action => "error"
      return
    end
    if user.id == @blogcast.user.id
      @error = "Unable to add sms notification for \"#{@blogcast.title}\". You can not be notified about your own blogcasts."
      render :action => "error"
      return
    end
    #MVR - do not allow the same notification multiple times
    @sms_blogcast_notification = SmsBlogcastNotification.find(:first, :conditions => {:user_id => user.id, :blogcast_id => @blogcast.id})
    if !@sms_blogcast_notification.nil?
      @error = "Unable to add sms notification for \"#{@blogcast.title}\". You were already being notified."
      render :action => "error"
      return
    end
    #MVR - add to database
    @sms_blogcast_notification = SmsBlogcastNotification.new
    @sms_blogcast_notification.user_id = user.id
    @sms_blogcast_notification.blogcast_id = @blogcast.id
    @sms_blogcast_notification.save
    #TODO: handle error
  end

  def destroy
    @blogcast = Blogcast.find(params[:blogcast_id])
    if @blogcast.nil?
      @error = "Unable to destroy sms notification for blogcast. Blogcast does not exist."
      render :action => "error"
      return
    end
    user = current_user
    #MVR - make sure user is signed in
    if user.nil?
      @error = "Unable to destroy sms notification for \"#{@blogcast.title}\". You are not signed in."
      render :action => "error"
      return
    end
    #MVR - delete from to database
    @sms_blogcast_notification = SmsBlogcastNotification.find(:first, :conditions => {:user_id => user.id, :blogcast_id => @blogcast.id})
    if !@sms_blogcast_notification.nil?
      @sms_blogcast_notification.destroy
    else
      @error = "Unable to destroy sms notification for \"#{@blogcast.title}\". It does not exist."
      render :action => "error"
      return
    end
  end
end
