class Users::SubscriptionsController < ApplicationController
  def index

    @current_user = current_user
    #MVR - find user by name or id
    if !params[:username].nil?
      @user = BlogcastrUser.find_by_username(params[:username])
      if @user.nil?
        render :file => "public/404.html", :layout => false, :status => 404
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
      @paginated_subscriptions = User.paginate_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id", @user.id], :page => @page, :per_page => 10)
      @id = Subscription.maximum(:id, :conditions => ["user_id = ?", @user.id])
    else
      @paginated_subscriptions = User.paginate_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id AND subscriptions.id <= ?", @user.id, @id], :page => @page, :per_page => 10)
    end
    @num_paginated_subscriptions = Subscription.count(:conditions => ["id <= ? AND user_id = ?", @id, @user.id])
    if @page * 10 < @num_paginated_subscriptions
      @next_page = @page + 1
    end
    if @page > 1 
      @previous_page = @page - 1
    end
    @num_first_subscription = ((@page - 1) * 10) + 1
    @num_last_subscription = @page * 10 
    if @num_last_subscription > @num_paginated_subscriptions
      @num_last_subscription = @num_paginated_subscriptions
    end
    #MVR - posts
    @num_posts = @user.posts.count
    @possesive_username = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
    @setting = @user.setting
    if @setting.use_background_image == false
      @theme = @setting.theme
    end
    @title = "Subscribers - " + @user.username
    render :layout => "/users/default"
  end

  def subscribers
    #MVR - find user by name or id
    if !params[:user_name].nil?
      @user = BlogcastrUser.find_by_name(params[:user_name])
      if @user.nil?
        respond_to do |format|
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>Couldn't find BlogcastrUser with NAME=\"#{params[:user_name]}\"</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"Couldn't find BlogcastrUser with NAME=\"#{params[:user_name]}\"\"]]", :status => :unprocessable_entity}
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
        format.xml {render :xml => @user.subscribers.to_xml(:only => [:id, :name], :include => :user)}
        format.json {render :json => @user.subscribers.to_json(:only => [:id, :name], :include => :user)}
    end
  end
end
