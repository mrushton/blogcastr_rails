class Users::SubscribersController < ApplicationController
  def index 
    @current_user = current_user
    #MVR - find user by name or id
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
    @num_subscriptions = @user.subscriptions.count
    #MVR - subscribers
    @num_subscribers = @user.subscribers.count
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
      @paginated_subscribers = User.paginate_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.subscribed_to = ? AND subscriptions.user_id = users.id", @user.id], :page => @page, :per_page => 10)
      @id = Subscription.maximum(:id, :conditions => ["subscribed_to = ?", @user.id])
    else
      @paginated_subscribers = User.paginate_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.subscribed_to = ? AND subscriptions.user_id = users.id AND subscriptions.id <= ?", @user.id, @id], :page => @page, :per_page => 10, :total_entries => @num_subscribers)
    end
    @num_paginated_subscribers = Subscription.count(:conditions => ["id <= ? AND subscribed_to = ?", @id, @user.id])
    if @page * 10 < @num_paginated_subscribers
      @next_page = @page + 1
    end
    if @page > 1 
      @previous_page = @page - 1
    end
    @num_first_subscriber = ((@page - 1) * 10) + 1
    @num_last_subscriber = @page * 10 
    if @num_first_subscriber > @num_paginated_subscribers
      @num_first_subscriber = 0
      @num_last_subscriber = 0
    else
      if @num_last_subscriber > @num_paginated_subscribers
        @num_last_subscriber = @num_paginated_subscribers
      end
    end
    #MVR - subscription
    if !@current_user.nil? && @current_user != @user
      @subscription = @current_user.subscriptions.find(:first, :conditions => { :subscribed_to => @user.id })
    end
    #MVR - posts
    @num_posts = @user.posts.count
    @possesive_username = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
    @setting = @user.setting
    if @setting.use_background_image == false
      @theme = @setting.theme
    end
    @title = "Subscribers - " + @user.username


    render :layout => "users/default"
  end
end
