class SubscriptionsController < ApplicationController
  #TODO: do not allow the same subscription multiple times
  #TODO: return a better error
  before_filter :authenticate

  def create
    user = current_user
    #TODO: handle error
    @blogcast = Blogcast.find(params[:blogcast_id])
    #MVR - can not subscribe to own blog
    #TODO: handle error 
    if user.id == @blogcast.user.id
      render :nothing => true
      return
    end
    #MVR - add to database
    @subscription = Subscription.new
    @subscription.user_id = user.id
    @subscription.blogcast_id = @blogcast.id 
    @subscription.save
    #MVR - subscribe to pubsub node
    #err = thrift_client.subscribe_to_pubsub_node(user.login, "dashboard", "/home/blogcastr.com/" + @blog.user.login + "/blog")
  end

  def destroy
    user = current_user 
    #TODO: handle error 
    @blogcast = Blogcast.find(params[:blogcast_id])
    @subscription = user.subscriptions.find(:first, :conditions => {:blogcast_id => @blogcast.id})
    #TODO: handle error
    @subscription.destroy
    #MVR - unsubscribe from pubsub node
    #err = thrift_client.unsubscribe_from_pubsub_node(user.login, "dashboard", "/home/blogcastr.com/" + @blog.user.login + "/blog", "")
  end
end
