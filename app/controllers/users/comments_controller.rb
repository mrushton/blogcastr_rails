class Users::CommentsController < ApplicationController
  before_filter :set_time_zone

  def index
    @current_user = current_user
    #MVR - find user by username
    if !params[:username].nil?
      @user = BlogcastrUser.find_by_username(params[:username])
      if @user.nil?
        respond_to do |format|
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>Couldn't find BlogcastrUser with NAME=\"#{params[:user_name]}\"</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"Couldn't find BlogcastrUser with NAME=\"#{params[:user_name]}\"\"]]", :status => :unprocessable_entity}
        end
        return
      end
    end





    
    #MVR - blogcasts
    @num_blogcasts = @user.blogcasts.count
    #MVR - comments
    @num_comments = @user.comments.count 
    #MVR - likes 
    @num_likes = Like.count(:conditions => {:user_id => @user.id})
    #MVR - subscriptions
    @subscriptions = User.find_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id LIMIT 16", @user.id])
    @num_subscriptions = @user.subscriptions.count
    #MVR - subscribers
    @subscribers = User.find_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.subscribed_to = ? AND subscriptions.user_id = users.id LIMIT 16", @user.id])
    @num_subscribers = @user.subscribers.count
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
      @paginated_comments = Comment.paginate_by_sql(["SELECT * FROM comments WHERE user_id = ?", @user.id], :page => @page, :per_page => 10)
      @id = Comment.maximum(:id, :conditions => ["user_id = ?", @user.id])
    else
      @paginated_comments = Comment.paginate_by_sql(["SELECT * FROM comments WHERE user_id = ? AND id <= ?", @user.id, @id], :page => @page, :per_page => 10)
    end
    @num_paginated_comments = Comment.count(:conditions => ["user_id = ? AND id <= ?", @user.id, @id])
    if @page * 10 < @num_paginated_comments
      @next_page = @page + 1
    end
    if @page > 1 
      @previous_page = @page - 1
    end
    @num_first_comment = ((@page - 1) * 10) + 1
    @num_last_comment = @page * 10 
    if @num_last_comment > @num_paginated_comments
      @num_last_comment = @num_paginated_comments
    end
    #MVR - posts
    @num_posts = @user.posts.count
    @possesive_username = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
    if @user.instance_of?(BlogcastrUser)
      @email_user_notification = EmailUserNotification.find(:first, :conditions => ["user_id = ? AND notifying_about = ?", @user.id, @user.id])
      @sms_user_notification = SmsUserNotification.find(:first, :conditions => ["user_id = ? AND notifying_about = ?", @user.id, @user.id])
    end
    @setting = @user.setting
    if @setting.use_background_image == false
      @theme = @setting.theme
    end
    @title = "Comments - " + @user.username


    render :layout => "users/default"

  end
end
