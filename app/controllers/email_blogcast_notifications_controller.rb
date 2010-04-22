class EmailBlogcastNotificationsController < ApplicationController
  def create
    @blogcast = Blogcast.find(params[:blogcast_id])
    if @blogcast.nil?
      @error = "Unable to add email notification for blogcast. Blogcast does not exist."
      render :action => "error"
      return
    end
    user = current_user
    #MVR - make sure user is signed in
    if user.nil?
      @error = "Unable to add email notification for \"#{@blogcast.title}\". You are not signed in."
      render :action => "error"
      return
    end
    if user.id == @blogcast.user.id
      @error = "Unable to add email notification for \"#{@blogcast.title}\". You can not be notified about your own blogcasts."
      render :action => "error"
      return
    end
    #MVR - do not allow the same notification multiple times
    @email_blogcast_notification = EmailBlogcastNotification.find(:first, :conditions => {:user_id => user.id, :blogcast_id => @blogcast.id})
    if !@email_blogcast_notification.nil?
      @error = "Unable to add email notification for \"#{@blogcast.title}\". You were already being notified."
      render :action => "error"
      return
    end
    #MVR - add to database
    @email_blogcast_notification = EmailBlogcastNotification.new
    @email_blogcast_notification.user_id = user.id
    @email_blogcast_notification.blogcast_id = @blogcast.id
    @email_blogcast_notification.delivered_by = "email"
    @email_blogcast_notification.save
    #TODO: handle error
  end

  def destroy
    @blogcast = Blogcast.find(params[:blogcast_id])
    if @blogcast.nil?
      @error = "Unable to destroy email notification for blogcast. Blogcast does not exist."
      render :action => "error"
      return
    end
    user = current_user
    #MVR - make sure user is signed in
    if user.nil?
      @error = "Unable to destroy email notification for \"#{@blogcast.title}\". You are not signed in."
      render :action => "error"
      return
    end
    #MVR - delete from to database
    @email_blogcast_notification = EmailBlogcastNotification.find(:first, :conditions => {:user_id => user.id, :blogcast_id => @blogcast.id})
    if !@email_blogcast_notification.nil?
      @email_blogcast_notification.destroy
    else
      @error = "Unable to destroy email notification for \"#{@blogcast.title}\". It does not exist."
      render :action => "error"
      return
    end
  end
end
