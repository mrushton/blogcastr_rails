class Blogcasts::PostsController < ApplicationController
  before_filter :set_time_zone
  before_filter :set_blogcast_time_zone
  before_filter :store_location

  def index 
    @blogcast_user = BlogcastrUser.find_by_username(params[:username])
    if @blogcast_user.nil?
      render :file => "public/404.html", :layout => false, :status => 404
      return
    end
    @blogcast = @blogcast_user.blogcasts.find(:first, :conditions => {:year => params[:year].to_i, :month => params[:month].to_i, :day => params[:day].to_i, :link_title => params[:title]})
    if @blogcast.nil?
        render :file => "public/404.html", :layout => false, :status => 404
      return
    end
    @user = current_user
    if !@user.nil?
      if @user.instance_of?(BlogcastrUser)
        #MVR - does user like blog or not
        if @user != @blogcast_user
          @like = @user.likes.find(:first, :conditions => {:blogcast_id => @blogcast.id}) 
        end
      end
    end
    #MVR - paginated posts 
    if params[:page].nil?
      @page = 1 
    else
      @page = params[:page].to_i
    end
    if !params[:id].nil?
      @id = params[:id].to_i
    end
    if @id.nil?
      @paginated_posts = Post.paginate_by_sql(["SELECT * FROM posts WHERE blogcast_id = ? ORDER BY id DESC", @blogcast.id], :page => @page, :per_page => 10)
      @id = Post.maximum(:id, :conditions => ["blogcast_id = ?", @blogcast.id])
    else
      @paginated_posts = Post.paginate_by_sql(["SELECT * FROM posts WHERE blogcast_id = ? AND id <= ? ORDER BY id DESC", @blogcast.id, @id], :page => @page, :per_page => 10)
    end
    @num_paginated_posts = Post.count(:conditions => ["blogcast_id = ? AND id <= ?", @blogcast.id, @id])
    if @page * 10 < @num_paginated_posts
      @next_page = @page + 1
    end
    if @page > 1 
       @previous_page = @page - 1
    end
    @num_first_post = ((@page - 1) * 10) + 1
    @num_last_post = @page * 10 
    if @num_last_post > @num_paginated_posts
      @num_last_post = @num_paginated_posts
    end







          #MVR - get settings
          @blogcast_setting = @blogcast_user.setting
          #MVR - tags
          @tags = BlogcastTag.find_by_sql(["SELECT * FROM blogcast_tags, tags WHERE blogcast_tags.blogcast_id = ? AND blogcast_tags.tag_id = tags.id", @blogcast.id])
          #MVR - posts 
          @posts = @blogcast.posts.find(:all, :order => "created_at DESC") 
          @num_posts = @blogcast.posts.count
          #MVR - comments
          @num_comments = @blogcast.comments.count
          @comments = @blogcast.comments.find(:all, :order => "created_at DESC", :limit => 2)
          @num_viewers = @blogcast.get_num_viewers + 1 
          #MVR - create view
          if !@user.nil?
            @blogcast.views.create :user_id => @user.id;
          else
            @blogcast.views.create;
          end
          @num_views = @blogcast.views.count
          #TODO: do not use find_by_sql
          @likes = User.find_by_sql(["SELECT users.* FROM likes, users WHERE likes.blogcast_id = ? AND likes.user_id = users.id LIMIT 21", @blogcast.id])
          @num_likes = @blogcast.likes.count 
          @blogcast_username_possesive = @blogcast_user.username + (@blogcast_user.username =~ /.*s$/ ? "'":"'s")
          @tweet_url = "http://twitter.com/home?status=%22" + @blogcast.title + "%22%20by%20" + @blogcast_user.username + ".%20" + username_blogcast_permalink_url(:username => @blogcast_user.username, :year => @blogcast.year, :month => @blogcast.month, :day => @blogcast.day, :title => @blogcast.link_title)
          if @user.instance_of?(BlogcastrUser)
            @email_blogcast_reminder = EmailBlogcastReminder.find(:first, :conditions => ["user_id = ? AND blogcast_id = ?", @user.id, @blogcast.id])
            @sms_blogcast_reminder = SmsBlogcastReminder.find(:first, :conditions => ["user_id = ? AND blogcast_id = ?", @user.id, @blogcast.id])
          end
          #MVR - blogcast user blogcasts
          @num_blogcast_user_blogcasts = @blogcast_user.blogcasts.count
          #MVR - blogcast user subscriptions 
          @num_blogcast_user_subscriptions = @blogcast_user.subscriptions.count
          #MVR - blogcast user subscribers 
          @num_blogcast_user_subscribers = @blogcast_user.subscribers.count
          #MVR - subscription
          if !@user.nil? && @user.id != @blogcast_user.id
            @subscription = @user.subscriptions.find(:first, :conditions => { :subscribed_to => @blogcast_user.id })
          end
          #MVR - theme 
          if @blogcast_setting.use_background_image == false
            @theme = @blogcast_setting.theme
          end
    @title = "Comments - " + @blogcast.title
    render :layout => "blogcasts/default"
    return
  end
end
