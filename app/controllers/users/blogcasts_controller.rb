class Users::BlogcastsController < ApplicationController
  before_filter :set_time_zone
  before_filter :set_blogcast_time_zone
  before_filter :set_facebook_session
  before_filter :store_location, :only => ["show"]
  helper_method :facebook_session

  def index
    #MVR - find user by username
    if params[:username].nil?
      respond_to do |format|
        format.html {render :file => "public/404.html", :layout => false, :status => 404}
        format.xml {render :xml => "<errors><error>Couldn't find BlogcastrUser with NAME=\"#{params[:user_name]}\"</error></errors>", :status => :unprocessable_entity}
        format.json {render :json => "[[\"Couldn't find BlogcastrUser with NAME=\"#{params[:user_name]}\"\"]]", :status => :unprocessable_entity}
      end
      return
    end
    @profile_user = BlogcastrUser.find_by_username(params[:username])
    if @profile_user.nil?
      respond_to do |format|
        format.html {render :file => "public/404.html", :layout => false, :status => 404}
        format.xml {render :xml => "<errors><error>Couldn't find BlogcastrUser with NAME=\"#{params[:user_name]}\"</error></errors>", :status => :unprocessable_entity}
        format.json {render :json => "[[\"Couldn't find BlogcastrUser with NAME=\"#{params[:user_name]}\"\"]]", :status => :unprocessable_entity}
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
          @paginated_blogcasts = Blogcast.paginate_by_sql(["SELECT * FROM blogcasts WHERE user_id = ? ORDER BY id DESC", @profile_user.id], :page => @page, :per_page => 10)
          @id = Blogcast.maximum(:id, :conditions => ["user_id = ?", @profile_user.id])
        else
          @paginated_blogcasts = Blogcast.paginate_by_sql(["SELECT * FROM blogcasts WHERE user_id = ? AND id <= ? ORDER BY id DESC", @profile_user.id, @id], :page => @page, :per_page => 10, :total_entries => @num_blogcasts)
        end
        @num_paginated_blogcasts = Blogcast.count(:conditions => ["user_id = ? AND id <= ?", @profile_user.id, @id])
        if @page * 10 < @num_paginated_blogcasts
          @next_page = @page + 1
        end
        if @page > 1 
          @previous_page = @page - 1
        end
        @num_first_blogcast = ((@page - 1) * 10) + 1
        #if @num_subscribers == 0
        #  @num_first_subscriber = 0
        #end
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
        @profile_setting = @profile_user.setting
        if @profile_setting.use_background_image == false
          @theme = @profile_setting.theme
        end
        @title = @profile_user_username_possesive + " blogcasts"
        render :layout => "profile"
      }
      #TODO: limit result set and order by most recent 
      format.xml {render :xml => @profile_user.subscribers.to_xml(:only => [:id, :name], :include => :user)}
      format.json {render :json => @profile_user.subscribers.to_json(:only => [:id, :name], :include => :user)}
      format.rss {
        #MVR - blogcasts
        @blogcasts = @profile_user.blogcasts.find(:all, :limit => 10, :order => "created_at DESC")
        #MVR - possesive names 
        @profile_user_username_possesive = @profile_user.username + (@profile_user.username =~ /.*s$/ ? "'":"'s")
        @profile_user_full_name_possesive = @profile_user.username + (@profile_user.username =~ /.*s$/ ? "'":"'s")
        render :layout => false
      }
    end
  end

  def recent 
    #MVR - find user by name or id
    if !params[:username].nil?
      @user = BlogcastrUser.find_by_username(params[:username])
      if @user.nil?
        respond_to do |format|
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>Couldn't find BlogcastrUser with NAME=\"#{params[:username]}\"</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"Couldn't find BlogcastrUser with NAME=\"#{params[:username]}\"\"]]", :status => :unprocessable_entity}
        end
        return
      end
    else
      begin
        @user = BlogcastrUser.find(params[:user_id])
      rescue ActiveRecord::RecordNotFound => error
        respond_to do |format|
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>#{error.message}</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"#{error.message}\"]]", :status => :unprocessable_entity}
        end
        return
      end
    end
    respond_to do |format|
        format.html
        #TODO: limit result set and order by most recent 
        format.xml {render :xml => @user.blogcasts.find(:all, :conditions => ["starting_at < ? AND starting_at > ?", Time.zone.now, 1.month.ago], :limit => 3).to_xml}
        format.json {render :json => @user.blogcasts.find(:all, :conditions => ["starting_at < ? AND starting_at > ?", Time.zone.now, 1.month.ago], :limit => 3).to_json}
    end
  end

  def upcoming 
    #MVR - find user by name or id
    if !params[:username].nil?
      @user = BlogcastrUser.find_by_username(params[:username])
      if @user.nil?
        respond_to do |format|
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>Couldn't find BlogcastrUser with NAME=\"#{params[:username]}\"</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"Couldn't find BlogcastrUser with NAME=\"#{params[:username]}\"\"]]", :status => :unprocessable_entity}
        end
        return
      end
    else
      begin
        @user = BlogcastrUser.find(params[:user_id])
      rescue ActiveRecord::RecordNotFound => error
        respond_to do |format|
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>#{error.message}</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"#{error.message}\"]]", :status => :unprocessable_entity}
        end
        return
      end
    end
    respond_to do |format|
        format.html
        #TODO: limit result set and order by most recent 
        format.xml {render :xml => @user.blogcasts.find(:all, :conditions => ["starting_at > ?", Time.zone.now], :limit => 3).to_xml}
        format.json {render :json => @user.blogcasts.find(:all, :conditions => ["starting_at > ?", Time.zone.now], :limit => 3).to_json}
    end
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
        @profile_setting = @profile_user.setting
        if @profile_setting.use_background_image == false
          @theme = @profile_setting.theme
        end
        @title = @profile_user_username_possesive + " blogcasts"
        render :layout => "profile"
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
            @comment = Comment.new(:from => "Web")
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
          #MVR - subscribers
          @num_subscribers = @blogcast_user.subscribers.count
          #MVR - subscriptions
          @num_subscriptions = @blogcast_user.subscriptions.count
          #MVR - blogcasts
          @num_blogcasts = @blogcast_user.blogcasts.count
          #MVR - theme 
          if @blogcast_setting.use_background_image == false
            @theme = @blogcast_setting.theme
          end
        }
        #TODO: limit result set and order by most recent 
        format.xml {render :xml => @blogcast.to_xml(:include => :posts)}
        format.json {render :json => @blogcast.to_json(:include => :posts)}
    end
    return
  end
end
