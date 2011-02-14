class Blogcasts::LikesController < ApplicationController
  before_filter :set_time_zone
  before_filter :set_blogcast_time_zone
  before_filter :store_location

  def index 
    @user = BlogcastrUser.find_by_username(params[:username])
    if @user.nil?
      render :file => "public/404.html", :layout => false, :status => 404
      return
    end
    @blogcast = @user.blogcasts.find(:first, :conditions => { :year => params[:year].to_i, :month => params[:month].to_i, :day => params[:day].to_i, :link_title => params[:title] })
    if @blogcast.nil?
        render :file => "public/404.html", :layout => false, :status => 404
      return
    end
    @current_user = current_user
    if !@current_user.nil?
      if @current_user.instance_of?(BlogcastrUser)
        #MVR - does user like blog or not
        if @current_user != @user
          @like = @current_user.likes.find(:first, :conditions => { :blogcast_id => @blogcast.id }) 
        end
      end
    end
    #MVR - paginated likes 
    if params[:page].nil?
      @page = 1 
    else
      @page = params[:page].to_i
    end
    if !params[:id].nil?
      @id = params[:id].to_i
    end
    if @id.blank?
      @paginated_likes = User.paginate_by_sql(["SELECT users.* FROM blogcasts, likes, users WHERE blogcasts.id = ? AND blogcasts.id = likes.blogcast_id AND likes.user_id = users.id", @blogcast.id], :page => @page, :per_page => 10)
      @id = Like.maximum(:id, :conditions => ["blogcast_id = ?", @blogcast.id])
    else
      @paginated_likes = User.paginate_by_sql(["SELECT users.* FROM blogcasts, likes, users WHERE blogcasts.id = ? AND blogcasts.id = likes.blogcast_id AND likes.user_id = users.id AND likes.id <= ?", @blogcast.id, @id], :page => @page, :per_page => 10)
    end
    @num_paginated_likes = Like.count(:conditions => ["blogcast_id = ? AND id <= ?", @blogcast.id, @id])
    if @page * 10 < @num_paginated_likes
      @next_page = @page + 1
    end
    if @page > 1 
       @previous_page = @page - 1
    end
    @num_first_like = ((@page - 1) * 10) + 1
    if @num_first_like > @num_paginated_likes
      @num_first_like = 0
      @num_last_like = 0
    else
      @num_last_like = @page * 10 
      if @num_last_like > @num_paginated_likes
        @num_last_like = @num_paginated_likes
      end
    end
    #MVR - get settings
    @setting = @user.setting
    #MVR - posts 
    @num_posts = @blogcast.posts.count
    #MVR - comments
    @num_comments = @blogcast.comments.count
    #MVR - views
    @num_views = @blogcast.views.count
    #MVR - likes
    @num_likes = @blogcast.likes.count 
    #MVR - user blogcasts
    @num_user_blogcasts = @user.blogcasts.count
    #MVR - user subscriptions 
    @num_user_subscriptions = @user.subscriptions.count
    #MVR - user subscribers 
    @num_user_subscribers = @user.subscribers.count
    #MVR - subscription
    if !@current_user.nil? && @current_user != @user
      @subscription = @current_user.subscriptions.find(:first, :conditions => { :subscribed_to => @user.id })
    end
    #MVR - theme 
    if @setting.use_background_image == false
      @theme = @setting.theme
    end
    @title = "Likes - " + @blogcast.title
    render :layout => "blogcasts/default"
    return
  end
end
