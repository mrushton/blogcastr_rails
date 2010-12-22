class Blogcasts::BlogcastsController < ApplicationController
  before_filter :set_cache_headers
  before_filter :set_time_zone
  before_filter :set_blogcast_time_zone
  before_filter :store_location

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
          @setting = @blogcast_user.setting
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
          if !@user.nil? && @user.id != @blogcast_user.id
            @subscription = @user.subscriptions.find(:first, :conditions => { :subscribed_to => @blogcast_user.id })
          end
          #MVR - theme 
          if @setting.use_background_image == false
            @theme = @setting.theme
          end
        }
        #TODO: limit result set and order by most recent 
        format.xml { render :xml => @blogcast.to_xml(:include => :posts) }
        format.json { render :json => @blogcast.to_json(:include => :posts) }
    end
  end
end
