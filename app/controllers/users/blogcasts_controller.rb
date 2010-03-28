class Users::BlogcastsController < ApplicationController
  before_filter :set_time_zone
  before_filter :set_blogcast_time_zone
  before_filter :set_facebook_session
  before_filter :store_location, :only => ["show"]
  helper_method :facebook_session

  def index
    #MVR - find user by name or id
    if !params[:username].nil?
      @blogcasts_user = BlogcastrUser.find_by_username(params[:username])
      if @blogcasts_user.nil?
        respond_to do |format|
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>Couldn't find BlogcastrUser with NAME=\"#{params[:username]}\"</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"Couldn't find BlogcastrUser with NAME=\"#{params[:username]}\"\"]]", :status => :unprocessable_entity}
        end
        return
      end
    else
      begin
        @blogcasts_user = BlogcastrUser.find(params[:user_id])
      rescue ActiveRecord::RecordNotFound => error
        respond_to do |format|
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>#{error.message}</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"#{error.message}\"]]", :status => :unprocessable_entity}
        end
        return
      end
    end
    @blogcasts = @blogcasts_user.blogcasts
    @blogcasts_user_username_possesive = @blogcasts_user.username + (@blogcasts_user.username =~ /.*s$/ ? "'":"'s")
    @blogcasts_user_full_name = @blogcasts_user.setting.full_name
    @blogcasts_user_full_name_possesive = @blogcasts_user_full_name + (@blogcasts_user_full_name =~ /.*s$/ ? "'":"'s")
    respond_to do |format|
        format.html
        #TODO: limit result set and order by most recent 
        format.xml {render :xml => @blogcasts.to_xml}
        format.json {render :json => @blogcasts.to_json}
        format.rss {render :layout => false}
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
    if !params[:year].nil? && !params[:month].nil? && !params[:day].nil? && !params[:title].nil?
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
    else
      begin
        @blogcast = @blogcast_user.blogcasts.find(params[:blogcast_id])
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
        format.html do
          #MVR - get settings
          @blogcast_setting = @blogcast_user.setting
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
          #MVR - posts 
          @posts = @blogcast.posts.find(:all, :order => "created_at DESC") 
          @num_posts = @blogcast.posts.count
          #MVR - comments
          @num_comments = @blogcast.comments.count
          #TODO: live viewers
          @num_viewers = 0
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
            @email_blogcast_notification = EmailBlogcastNotification.find(:first, :conditions => ["user_id = ? AND blogcast_id = ?", @user.id, @blogcast.id])
            @sms_blogcast_notification = SmsBlogcastNotification.find(:first, :conditions => ["user_id = ? AND blogcast_id = ?", @user.id, @blogcast.id])
          end
          #MVR - subscribers
          @num_subscribers = @blogcast_user.subscribers.count
          #MVR - subscriptions
          @num_subscriptions = @blogcast_user.subscriptions.count
          #MVR - blogcasts
          @num_blogcasts = @blogcast_user.blogcasts.count
          #MVR - subscriptions
          if @blogcast_setting.use_background_image == false
            @theme = @blogcast_setting.theme
          end
        end
        #TODO: limit result set and order by most recent 
        format.xml {render :xml => @blogcast.to_xml(:include => :posts)}
        format.json {render :json => @blogcast.to_json(:include => :posts)}
    end
    return
  end
end
