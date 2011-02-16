class Users::BlogcastsController < ApplicationController
  before_filter :set_cache_headers
  before_filter :set_time_zone
  before_filter :set_blogcast_time_zone
  before_filter :store_location, :only => [ "show" ]

  def index
    #MVR - find user by username
    if params[:username].nil?
      render :file => "public/404.html", :layout => false, :status => 404
      return
    end
    @user = BlogcastrUser.find_by_username(params[:username])
    if @user.nil?
      render :file => "public/404.html", :layout => false, :status => 404
      return
    end
    @current_user = current_user
    @setting = @user.setting
    #MVR - stats
    @num_blogcasts = @user.blogcasts.count
    @num_subscriptions = @user.subscriptions.count
    @num_subscribers = @user.subscribers.count
    @num_posts = @user.posts.count
    @num_comments = @user.comments.count 
    @num_likes = Like.count(:conditions => { :user_id => @user.id })
    #MVR - paginated blogcasts 
    if params[:page].nil?
      @page = 1 
    else
      @page = params[:page].to_i
    end
    if !params[:page].nil?
      @id = params[:id].to_i
    end
    if @id.blank?
      @paginated_blogcasts = Blogcast.paginate_by_sql([ "SELECT * FROM blogcasts WHERE user_id = ? ORDER BY id DESC", @user.id ], :page => @page, :per_page => 10)
      @id = Blogcast.maximum(:id, :conditions => [ "user_id = ?", @user.id ])
    else
      @paginated_blogcasts = Blogcast.paginate_by_sql([ "SELECT * FROM blogcasts WHERE user_id = ? AND id <= ? ORDER BY id DESC", @user.id, @id ], :page => @page, :per_page => 10, :total_entries => @num_blogcasts)
    end
    @num_paginated_blogcasts = Blogcast.count(:conditions => [ "user_id = ? AND id <= ?", @user.id, @id ])
    if @page * 10 < @num_paginated_blogcasts
      @next_page = @page + 1
    end
    if @page > 1 
      @previous_page = @page - 1
    end
    @num_first_blogcast = ((@page - 1) * 10) + 1
    if @num_first_blogcast > @num_paginated_blogcasts
      @num_first_blogcast = 0
      @num_last_blogcast = 0
    else
      @num_last_blogcast = @page * 10 
      if @num_last_blogcast > @num_paginated_blogcasts
        @num_last_blogcast = @num_paginated_blogcasts
      end
    end
    #MVR - subscription
    if !@current_user.nil? && @current_user != @user
      @subscription = @current_user.subscriptions.find(:first, :conditions => { :subscribed_to => @user.id })
    end
    if @setting.use_background_image == false
      @theme = @setting.theme
    end
    @possesive_username = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
    @title = "Blogcasts - " + @user.username
    render :layout => "users/default"
  end

  def tagged
    #MVR - find user by username
    if params[:username].nil?
      render :file => "public/404.html", :layout => false, :status => 404
      return
    end
    @user = BlogcastrUser.find_by_username(params[:username])
    if @user.nil?
      render :file => "public/404.html", :layout => false, :status => 404
      return
    end
    @tag_name = params[:tag]
    @current_user = current_user
    @setting = @user.setting
    #MVR - stats
    @num_blogcasts = @user.blogcasts.count
    @num_subscriptions = @user.subscriptions.count
    @num_subscribers = @user.subscribers.count
    @num_posts = @user.posts.count
    @num_comments = @user.comments.count 
    @num_likes = Like.count(:conditions => { :user_id => @user.id })
    #MVR - paginated blogcasts 
    if params[:page].nil?
      @page = 1 
    else
      @page = params[:page].to_i
    end
    if !params[:page].nil?
      @id = params[:id].to_i
    end
    if @id.blank?
      @paginated_blogcasts = Blogcast.paginate_by_sql(["SELECT blogcasts.* FROM tags, blogcast_tags, blogcasts WHERE tags.user_id = ? AND tags.name = ? AND tags.id = blogcast_tags.tag_id AND blogcast_tags.blogcast_id = blogcasts.id", @user.id, @tag_name], :page => @page, :per_page => 10)
      @id = Blogcast.maximum(:id, :conditions => [ "user_id = ?", @user.id ])
    else
      @paginated_blogcasts = Blogcast.paginate_by_sql(["SELECT blogcasts.* FROM tags, blogcast_tags, blogcasts WHERE tags.user_id = ? AND tags.name = ? AND tags.id = blogcast_tags.tag_id AND blogcast_tags.blogcast_id = blogcasts.id AND id <= ?", @user.id, @tag_name, @id], :page => @page, :per_page => 10, :total_entries => @num_blogcasts)
    end
    @num_paginated_blogcasts = Blogcast.count(:conditions => [ "tags.user_id = ? AND tags.name = ?", @user.id, @tag_name ], :joins => [ "LEFT JOIN blogcast_tags ON blogcast_tags.blogcast_id = blogcasts.id", "LEFT JOIN tags ON tags.id = blogcast_tags.tag_id" ])
    if @page * 10 < @num_paginated_blogcasts
      @next_page = @page + 1
    end
    if @page > 1 
      @previous_page = @page - 1
    end
    @num_first_blogcast = ((@page - 1) * 10) + 1
    if @num_first_blogcast > @num_paginated_blogcasts
      @num_first_blogcast = 0
      @num_last_blogcast = 0
    else
      @num_last_blogcast = @page * 10 
      if @num_last_blogcast > @num_paginated_blogcasts
        @num_last_blogcast = @num_paginated_blogcasts
      end
    end
    #MVR - subscription
    if !@current_user.nil? && @current_user != @user
      @subscription = @current_user.subscriptions.find(:first, :conditions => { :subscribed_to => @user.id })
    end
    if @setting.use_background_image == false
      @theme = @setting.theme
    end
    @possesive_username = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
    @title = "Tagged/" + @tag_name + " - " + @user.username
    render :layout => "users/default"
  end
end
