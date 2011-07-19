class Users::SubscriptionsController < ApplicationController
  #MVR - needed to work around CSRF for REST api
  #TODO: add CSRF before filter for standard authentication only, other option is to modify Rails to bypass CSRF for certain user agents
  skip_before_filter :verify_authenticity_token
  before_filter do |controller|
    if controller.params[:authentication_token].nil?
      controller.authenticate
    else 
      controller.rest_authenticate
    end
  end

  def create
    if params[:authentication_token].nil?
      @current_user = current_user
    else 
      @current_user = rest_current_user
    end
    begin
      @subscription_user = User.find(params[:user_id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.js {
          @error = "User #{params[:user_id]} does not exist."
          render :action => "error"
        }
        format.xml { render :xml => "<errors><error>User #{params[:user_id]} does not exist</error></errors>", :status => :unprocessable_entity } end
      return
    end
    #MVR - can not subscribe to yourself
    if @current_user == @subscription_user
      respond_to do |format|
        format.js {
          @error = "Unable to subscribe to yourself."
          render :action => "error"
        }
        format.xml { render :xml => "<errors><error>Unable to subscribe to yourself</error></errors>", :status => :unprocessable_entity }
      end
      return
    end
    #MVR - do not allow the same subscription multiple times
    @subscription = Subscription.find(:first, :conditions => { :user_id => @current_user.id, :subscribed_to => @subscription_user.id })
    if !@subscription.nil? 
      respond_to do |format|
        format.js {
          @error = "You are already subscribed to #{@subscription_user.username}."
          render :action => "error"
        }
        format.xml { render :xml => "<errors><error>You are already subscribed to #{@subscription_user.username}</error></errors>", :status => :unprocessable_entity }
      end
      return
    end
    #MVR - create subscription 
    @subscription = Subscription.new
    @subscription.user_id = @current_user.id
    @subscription.subscribed_to = @subscription_user
    if !@subscription.save
      respond_to do |format|
        format.js {
          @error = "Failed to save subscription."
          render :action => "error"
        }
        format.xml { render :xml => @subscription.errors, :status => :unprocessable_entity }
      end
      return
    end
    respond_to do |format|
      format.js { }
      format.xml {
        head :ok
      }
    end
  end

  def destroy 
    if params[:authentication_token].nil?
      @current_user = current_user
    else 
      @current_user = rest_current_user
    end
    begin
      @subscription_user = User.find(params[:user_id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.js {
          @error = "User #{params[:user_id]} does not exist."
          render :action => "error"
        }
        format.xml { render :xml => "<errors><error>User #{params[:user_id]} does not exist</error></errors>", :status => :unprocessable_entity }
      end
      return
    end
    #MVR - find the subscription object
    @subscription = @current_user.subscriptions.find(:first, :conditions => [ "subscribed_to = ?", @subscription_user.id ])
    if @subscription.nil?
      respond_to do |format|
        format.js {
          @error = "You are not subscribed to #{@subscription_user.username}."
          render :action => "error"
        }
        format.xml { render :xml => "<errors><error>You are not subscribed to #{@subscription_user.username}</error></errors>", :status => :unprocessable_entity }
      end
      return
    end
    #MVR - no meaningful return value
    @subscription.destroy
    respond_to do |format|
      format.js { }
      format.xml {
        head :ok
      }
    end
  end

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
    @num_subscriptions = @user.subscriptions.count
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
    if @num_first_subscription > @num_paginated_subscriptions
      @num_first_subscription = 0
      @num_last_subscription = 0
    else
      @num_last_subscription = @page * 10 
      if @num_last_subscription > @num_paginated_subscriptions
        @num_last_subscription = @num_paginated_subscriptions
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
