class SmsBlogcastRemindersController < ApplicationController
  def create
    @blogcast = Blogcast.find(params[:blogcast_id])
    if @blogcast.nil?
      @error = "Unable to add sms reminder for blogcast. Blogcast does not exist."
      render :action => "error"
      return
    end
    user = current_user
    #MVR - make sure user is signed in
    if user.nil?
      @error = "Unable to add sms reminder for \"#{@blogcast.title}\". You are not signed in."
      render :action => "error"
      return
    end
    if user.id == @blogcast.user.id
      @error = "Unable to add sms reminder for \"#{@blogcast.title}\". You can not be notified about your own blogcasts."
      render :action => "error"
      return
    end
    #MVR - do not allow the same reminder multiple times
    @sms_blogcast_reminder = SmsBlogcastReminder.find(:first, :conditions => {:user_id => user.id, :blogcast_id => @blogcast.id})
    if !@sms_blogcast_reminder.nil?
      @error = "Unable to add sms reminder for \"#{@blogcast.title}\". You were already being notified."
      render :action => "error"
      return
    end
    #MVR - add to database
    @sms_blogcast_reminder = SmsBlogcastReminder.new
    @sms_blogcast_reminder.user_id = user.id
    @sms_blogcast_reminder.blogcast_id = @blogcast.id
    @sms_blogcast_reminder.delivered_by = "sms"
    @sms_blogcast_reminder.save
    #TODO: handle error
  end

  def destroy
    @blogcast = Blogcast.find(params[:blogcast_id])
    if @blogcast.nil?
      @error = "Unable to destroy sms reminder for blogcast. Blogcast does not exist."
      render :action => "error"
      return
    end
    user = current_user
    #MVR - make sure user is signed in
    if user.nil?
      @error = "Unable to destroy sms reminder for \"#{@blogcast.title}\". You are not signed in."
      render :action => "error"
      return
    end
    #MVR - delete from to database
    @sms_blogcast_reminder = SmsBlogcastReminder.find(:first, :conditions => {:user_id => user.id, :blogcast_id => @blogcast.id})
    if !@sms_blogcast_reminder.nil?
      @sms_blogcast_reminder.destroy
    else
      @error = "Unable to destroy sms reminder for \"#{@blogcast.title}\". It does not exist."
      render :action => "error"
      return
    end
  end
end
