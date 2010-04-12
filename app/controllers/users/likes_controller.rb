class Users::LikesController < ApplicationController
  before_filter :set_time_zone

  def index
    @user = current_user
    #MVR - find user by name or id
    if !params[:username].nil?
      @profile_user = BlogcastrUser.find_by_username(params[:username])
      if @profile_user.nil?
        respond_to do |format|
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>Couldn't find BlogcastrUser with NAME=\"#{params[:user_name]}\"</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"Couldn't find BlogcastrUser with NAME=\"#{params[:user_name]}\"\"]]", :status => :unprocessable_entity}
        end
        return
      end
    end





    
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
      @paginated_likes = Blogcast.paginate_by_sql(["SELECT blogcasts.* FROM likes, blogcasts WHERE likes.user_id = ? AND likes.blogcast_id = blogcasts.id", @profile_user.id], :page => @page, :per_page => 10)
      @id = Like.maximum(:id, :conditions => ["user_id = ?", @profile_user.id])
    else
      @paginated_likes = Blogcast.paginate_by_sql(["SELECT blogcasts.* FROM likes, blogcasts WHERE likes.user_id = ? AND likes.blogcast_id = blogcasts.id AND likes.id <= ?", @profile_user.id, @id], :page => @page, :per_page => 10, :total_entries => @num_likes)
    end
    @num_paginated_likes = Like.count(:conditions => ["id <= ? AND user_id = ?", @id, @profile_user.id])
    if @page * 10 < @num_paginated_likes
      @next_page = @page + 1
    end
    if @page > 1 
      @previous_page = @page - 1
    end
    @num_first_like = ((@page - 1) * 10) + 1
    #if @num_subscribers == 0
    #  @num_first_subscriber = 0
    #end
    @num_last_like = @page * 10 
    if @num_last_like > @num_paginated_likes
      @num_last_like = @num_paginated_likes
    end
    #MVR - posts
    @num_posts = @profile_user.posts.count
    @profile_user_username_possesive = @profile_user.username + (@profile_user.username =~ /.*s$/ ? "'":"'s")
    @profile_user_username_possesive_escaped = @profile_user_username_possesive.gsub(/'/,"\\\\\'")
    if @user.instance_of?(BlogcastrUser)
      @email_user_notification = EmailUserNotification.find(:first, :conditions => ["user_id = ? AND notifying_about = ?", @user.id, @profile_user.id])
      @sms_user_notification = SmsUserNotification.find(:first, :conditions => ["user_id = ? AND notifying_about = ?", @user.id, @profile_user.id])
    end
    @profile_setting = @profile_user.setting
    if @profile_setting.use_background_image == false
      @theme = @profile_setting.theme
    end
    @title = @profile_user_username_possesive + " likes"


    respond_to do |format|
        format.html {render :layout => "profile"}
        #TODO: limit result set and order by most recent 
        format.xml {render :xml => @profile_user.subscribers.to_xml(:only => [:id, :name], :include => :user)}
        format.json {render :json => @profile_user.subscribers.to_json(:only => [:id, :name], :include => :user)}
    end
  end
end
