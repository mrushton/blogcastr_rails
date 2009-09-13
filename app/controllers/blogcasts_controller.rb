class BlogcastsController < ApplicationController
  def index
    @blogcast_user = User.find_by_name(params[:username])
    if @blogcast_user.nil?
      #MVR - treat this as a 404 error
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
      return
    end
    @blogcast = @blogcast_user.blogcast
    #MVR - ActiveRecord only throws an exception when calling find with an id
    #MVR - get settings
    @blogcast_setting = @blogcast_user.setting
    @user = current_user
    if !@user.nil?
      #MVR - is user subscribed to blog or not
      if @user.name != @blogcast_user.name
        @subscription = @user.subscriptions.find(:first, :conditions => {:blogcast_id => @blogcast.id })
        @blogcast_owner = false
      else
        @blogcast_owner = true
      end
      #MVR - comment objects
      @text_comment = TextComment.new(:from => "Web")
    end
    #MVR - retrieve blog posts in reverse chronological order
    @posts = @blogcast.posts.find(:all, :order => "created_at DESC") 
    #MVR - seems like what I want is to go through and create a facebook user id -> info hash
    #MVR - first make a list of all facebook uids needed then call facebooker then parse
  end
end
