class Users::CommentsController < ApplicationController
  before_filter :set_time_zone

  def index
    @current_user = current_user
    #MVR - find user by username
    if !params[:username].nil?
      @user = BlogcastrUser.find_by_username(params[:username])
      if @user.nil?
        render :file => "public/404.html", :layout => false, :status => 404
        return
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
    if !params[:id].nil?
      @id = params[:id].to_i
    end
    if @id.blank?
      @paginated_comments = Comment.paginate_by_sql(["SELECT * FROM comments WHERE user_id = ? ORDER BY id DESC", @user.id], :page => @page, :per_page => 10)
      @id = Comment.maximum(:id, :conditions => ["user_id = ?", @user.id])
    else
      @paginated_comments = Comment.paginate_by_sql(["SELECT * FROM comments WHERE user_id = ? AND id <= ? ORDER BY id DESC", @user.id, @id], :page => @page, :per_page => 10)
    end
    @num_paginated_comments = Comment.count(:conditions => ["user_id = ? AND id <= ?", @user.id, @id])
    if @page * 10 < @num_paginated_comments
      @next_page = @page + 1
    end
    if @page > 1 
      @previous_page = @page - 1
    end
    @num_first_comment = ((@page - 1) * 10) + 1
    if @num_first_comment > @num_paginated_comments
      @num_first_comment = 0
      @num_last_comment = 0
    else
      @num_last_comment = @page * 10 
      if @num_last_comment > @num_paginated_comments
        @num_last_comment = @num_paginated_comments
      end
    end
    #MVR - subscription
    if !@current_user.nil? && @current_user != @user
      @subscription = @current_user.subscriptions.find(:first, :conditions => { :subscribed_to => @user.id })
    end
    #MVR - posts
    if !@setting.use_background_image
      @theme = @setting.theme
    end
    @title = "Comments - " + @user.username
    render :layout => "users/default"
  end
end
