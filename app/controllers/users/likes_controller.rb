class Users::LikesController < ApplicationController
  before_filter :set_time_zone

  def index
    @current_user = current_user
    #MVR - find user by name
    if !params[:username].nil?
      @user = BlogcastrUser.find_by_username(params[:username])
      if @user.nil?
        render :file => "public/404.html", :layout => false, :status => 404
      end
    end
    @setting = @user.setting
    @possesive_username = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
    #MVR - stats
    @num_blogcasts = @user.blogcasts.count
    @num_subscriptions = @user.subscriptions.count
    @num_subscribers = @user.subscribers.count
    @num_posts = @user.posts.count
    @num_comments = @user.comments.count 
    @num_likes = Like.count(:conditions => {:user_id => @user.id})
    #MVR - paginated subscribers 
    if params[:page].nil?
      @page = 1 
    else
      @page = params[:page].to_i
    end
    if !params[:page].nil?
      @id = params[:id].to_i
    end
    if @id.blank?
      @paginated_likes = Blogcast.paginate_by_sql([ "SELECT blogcasts.* FROM likes, blogcasts WHERE likes.user_id = ? AND likes.blogcast_id = blogcasts.id", @user.id], :page => @page, :per_page => 10)
      @id = Like.maximum(:id, :conditions => [ "user_id = ?", @user.id ])
    else
      @paginated_likes = Blogcast.paginate_by_sql([ "SELECT blogcasts.* FROM likes, blogcasts WHERE likes.user_id = ? AND likes.blogcast_id = blogcasts.id AND likes.id <= ?", @user.id, @id ], :page => @page, :per_page => 10, :total_entries => @num_likes)
    end
    @num_paginated_likes = Like.count(:conditions => [ "id <= ? AND user_id = ?", @id, @user.id ])
    if @page * 10 < @num_paginated_likes
      @next_page = @page + 1
    end
    if @page > 1 
      @previous_page = @page - 1
    end
    @num_first_like = ((@page - 1) * 10) + 1
    @num_last_like = @page * 10 
    if @num_last_like > @num_paginated_likes
      @num_last_like = @num_paginated_likes
    end
    #MVR - subscription
    if !@current_user.nil? && @current_user != @user
      @subscription = @current_user.subscriptions.find(:first, :conditions => { :subscribed_to => @user.id })
    end
    if !@setting.use_background_image
      @theme = @setting.theme
    end
    @title = "Likes - " + @user.username
    render :layout => "users/default"
  end
end
