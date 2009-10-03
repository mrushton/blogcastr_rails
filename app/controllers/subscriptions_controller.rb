class SubscriptionsController < ApplicationController
  def create
    @profile_user = User.find(params[:user_id])
    if @profile_user.nil?
      @error = "Unable to subscribe to #{@profile_user.name}. User does not exist."
      render :action => "error"
      return
    end
    user = current_user
    #MVR - make sure user is signed in
    if user.nil?
      @error = "Unable to subscribe to #{@profile_user.name}. You are not signed in."
      render :action => "error"
      return
    end
    if user.id == @profile_user.id
      @error = "Unable to subscribe to #{@profile_user.name}. You can not subscribe to yourself."
      render :action => "error"
      return
    end
    #MVR - do not allow the same subscription multiple times
    @subscription = Subscription.find(:first, :conditions => {:user_id => user.id, :subscribed_to => @profile_user.id})
    if !@subscription.nil? 
      @error = "Unable to subscribe to #{@profile_user.name}. You are already subscribed."
      render :action => "error"
      return
    end
    #MVR - add to database
    @subscription = Subscription.new
    @subscription.user_id = user.id
    @subscription.subscribed_to = @profile_user
    @subscription.save
    #MVR - subscribe to pubsub node
    #err = thrift_client.subscribe_to_pubsub_node(user.login, "dashboard", "/home/blogcastr.com/" + @blog.user.login + "/blog")
  end

  def destroy
    user = current_user 
    #MVR - make sure user is signed in
    if user.nil?
      @error = "Unable to unsubscribe. You are not signed in."
      render :action => "error"
      return
    end
    begin
      @subscription = user.subscriptions.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @error = "Unable to unsubscribe. Invalid subscription id."
      render :action => "error"
      return
    end
    @profile_user = @subscription.subscribed_to
    @subscription.destroy
    #MVR - unsubscribe from pubsub node
    #err = thrift_client.unsubscribe_from_pubsub_node(user.login, "dashboard", "/home/blogcastr.com/" + @blog.user.login + "/blog", "")
  end
end
