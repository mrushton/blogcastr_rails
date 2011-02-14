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
      respond_to do |format|
        format.html {render :file => "public/404.html", :layout => false, :status => 404}
        format.xml {render :xml => "<errors><error>Couldn't find BlogcastrUser with NAME=\"#{params[:username]}\"</error></errors>", :status => :unprocessable_entity}
        format.json {render :json => "[[\"Couldn't find BlogcastrUser with NAME=\"#{params[:username]}\"\"]]", :status => :unprocessable_entity}
      end
      return
    end
    @profile_user = BlogcastrUser.find_by_username(params[:username])
    if @profile_user.nil?
      respond_to do |format|
        format.html {render :file => "public/404.html", :layout => false, :status => 404}
        format.xml {render :xml => "<errors><error>Couldn't find BlogcastrUser with NAME=\"#{params[:username]}\"</error></errors>", :status => :unprocessable_entity}
        format.json {render :json => "[[\"Couldn't find BlogcastrUser with NAME=\"#{params[:username]}\"\"]]", :status => :unprocessable_entity}
      end
      return
    end
    respond_to do |format|
      format.html {
        @user = current_user
        #MVR - blogcasts
        @num_blogcasts = @profile_user.blogcasts.count
        #MVR - comments
        @num_comments = @profile_user.comments.count 
        #MVR - likes 
        @num_likes = Like.count(:conditions => {:user_id => @profile_user.id})
        #MVR - subscriptions
        @subscriptions = User.find_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id LIMIT 16", @profile_user.id])
        @num_subscriptions = @profile_user.subscriptions.count
        #MVR - subscribers
        @subscribers = User.find_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.subscribed_to = ? AND subscriptions.user_id = users.id LIMIT 16", @profile_user.id])
        @num_subscribers = @profile_user.subscribers.count
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
          @paginated_blogcasts = Blogcast.paginate_by_sql(["SELECT blogcasts.* FROM tags, blogcast_tags, blogcasts WHERE tags.user_id = ? AND tags.name = ? AND tags.id = blogcast_tags.tag_id AND blogcast_tags.blogcast_id = blogcasts.id", @profile_user.id, params[:tag]], :page => @page, :per_page => 10)
          @id = Blogcast.maximum(:id, :conditions => ["user_id = ?", @profile_user.id])
        else
          @paginated_blogcasts = Blogcast.paginate_by_sql(["SELECT blogcasts.* FROM tags, blogcast_tags, blogcasts WHERE tags.user_id = ? AND tags.name = ? AND tags.id = blogcast_tags.tag_id AND blogcast_tags.blogcast_id = blogcasts.id AND id <= ?", @profile_user.id, params[:tag], @id], :page => @page, :per_page => 10, :total_entries => @num_blogcasts)
        end
        @num_paginated_blogcasts = Blogcast.count(:conditions => ["user_id = ? AND id <= ?", @profile_user.id, @id])
        if @page * 10 < @num_paginated_blogcasts
          @next_page = @page + 1
        end
        if @page > 1 
          @previous_page = @page - 1
        end
        @num_first_blogcast = ((@page - 1) * 10) + 1
        @num_last_blogcast = @page * 10 
        if @num_last_blogcast > @num_paginated_blogcasts
          @num_last_blogcast = @num_paginated_blogcasts
        end
        #MVR - posts
        @num_posts = @profile_user.posts.count
        @profile_user_username_possesive = @profile_user.username + (@profile_user.username =~ /.*s$/ ? "'":"'s")
        @profile_user_full_name_possesive = @profile_user.username + (@profile_user.username =~ /.*s$/ ? "'":"'s")
        @profile_user_username_possesive_escaped = @profile_user_username_possesive.gsub(/'/,"\\\\\'")
        if @user.instance_of?(BlogcastrUser)
          @email_user_notification = EmailUserNotification.find(:first, :conditions => ["user_id = ? AND notifying_about = ?", @user.id, @profile_user.id])
          @sms_user_notification = SmsUserNotification.find(:first, :conditions => ["user_id = ? AND notifying_about = ?", @user.id, @profile_user.id])
        end
        @setting = @profile_user.setting
        if @setting.use_background_image == false
          @theme = @setting.theme
        end
        render :layout => "users/profile"
      }
      #TODO: limit result set and order by most recent 
      format.xml {render :xml => @user.blogcasts.find(:all, :conditions => ["starting_at > ?", Time.zone.now], :limit => 3).to_xml}
      format.json {render :json => @user.blogcasts.find(:all, :conditions => ["starting_at > ?", Time.zone.now], :limit => 3).to_json}
    end
  end

  def show
    if !params[:username].nil?
      @blogcast_user = BlogcastrUser.find_by_username(params[:username])
      if @blogcast_user.nil?
        respond_to do |format|
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>Couldn't find BlogcastrUser with NAME=\"#{params[:username]}\"</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"Couldn't find BlogcastrUser with NAME=\"#{params[:username]}\"\"]]", :status => :unprocessable_entity}
        end
        return
      end
    else
      begin
        @blogcast_user = BlogcastrUser.find(params[:user_id])
      rescue ActiveRecord::RecordNotFound => error
        respond_to do |format|
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>#{error.message}</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"#{error.message}\"]]", :status => :unprocessable_entity}
        end
        return
      end
    end
    @blogcast = @blogcast_user.blogcasts.find(:first, :conditions => {:year => params[:year].to_i, :month => params[:month].to_i, :day => params[:day].to_i, :link_title => params[:title]})
    if @blogcast.nil?
      respond_to do |format|
        #TODO: better error messages
        format.html {render :file => "public/404.html", :layout => false, :status => 404}
        format.xml {render :xml => "<errors><error>Couldn't find Blogcast</error></errors>", :status => :unprocessable_entity}
        format.json {render :json => "[[\"Couldn't find Blogcast\"]]", :status => :unprocessable_entity}
      end
      return
    end
    respond_to do |format|
        format.html { 
          @user = current_user
          if !@user.nil?
            if @user.instance_of?(BlogcastrUser)
              #MVR - does user like blog or not
              if @user != @blogcast_user
                @like = @user.likes.find(:first, :conditions => {:blogcast_id => @blogcast.id}) 
              end
            end
            @comment = Comment.new(:from => "Web", :text => "Enter text here...")
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
          begin
    #num_viewers = CACHE.get("Blogcast:" + id.to_s + "-num_viewers") 
    #unless num_viewers 
      #CACHE.set("Blogcast:" + id.to_s + "-num_viewers", num_viewers, 30.seconds)
   # end
   #TODO: these rooms are created using an uppercase B but this needs to be lowercase
            @num_viewers = thrift_client.get_num_muc_room_occupants("blogcast." + @blogcast.id.to_s) + 1
            thrift_client_close
          rescue
            @num_viewers = 1 
          end
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
          if !@current_user.nil? && @current_user != @user
            @subscription = @current_user.subscriptions.find(:first, :conditions => { :subscribed_to => @user.id })
          end
          #MVR - theme 
          if @blogcast_setting.use_background_image == false
            @theme = @blogcast_setting.theme
          end
        }
        #TODO: limit result set and order by most recent 
        format.xml { render :xml => @blogcast.to_xml(:include => :posts) }
        format.json { render :json => @blogcast.to_json(:include => :posts) }
    end
  end
end
