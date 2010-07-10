class Users::ProfileController < ApplicationController
  before_filter :set_cache_headers
  before_filter :set_time_zone
  before_filter :store_location

  def index
    @user = current_user
    @profile_user = User.find_by_username(params[:username])
    if @profile_user.nil?
      #MVR - treat this as a 404 error
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
      return
    end
    if !@user.nil? && @user.id != @profile_user.id
      @subscription = @user.subscriptions.find(:first, :conditions => {:subscribed_to => @profile_user.id})
    end
    #MVR - upcoming blogcasts
    @upcoming_blogcasts = @profile_user.blogcasts.find(:all, :conditions => ["starting_at > ?", Time.zone.now], :order => "starting_at", :limit => 3)
    @num_upcoming_blogcasts = Blogcast.count(:conditions => ["user_id = ? AND starting_at > ?", @profile_user.id, Time.zone.now])
    #MVR - recent blogcasts
    @recent_blogcasts = @profile_user.blogcasts.find(:all, :conditions => ["starting_at < ? AND starting_at > ?", Time.zone.now, 1.month.ago], :order => "starting_at", :limit => 3)
    @num_recent_blogcasts = Blogcast.count(:conditions => ["user_id = ? AND starting_at < ? AND starting_at > ?", @profile_user.id, Time.zone.now, 1.month.ago])
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
    #MVR - posts
    @num_posts = @profile_user.posts.count
    #MVR - subscription blogcasts
    @upcoming_subscription_blogcasts = Blogcast.find_by_sql(["SELECT blogcasts.* FROM subscriptions, users, blogcasts WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id AND users.id = blogcasts.user_id AND blogcasts.starting_at > ? ORDER BY blogcasts.starting_at LIMIT 3", @profile_user.id, Time.zone.now])
    @recent_subscription_blogcasts = Blogcast.find_by_sql(["SELECT blogcasts.* FROM subscriptions, users, blogcasts WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id AND users.id = blogcasts.user_id AND blogcasts.starting_at < ? ORDER BY blogcasts.starting_at DESC LIMIT 3", @profile_user.id, Time.zone.now])
    @profile_username_possesive = @profile_user.username + (@profile_user.username =~ /.*s$/ ? "'":"'s")
    @profile_username_possesive_escaped = @profile_username_possesive.gsub(/'/,"\\\\\'")
    if @user.instance_of?(BlogcastrUser)
      @email_user_notification = EmailUserNotification.find(:first, :conditions => ["user_id = ? AND notifying_about = ?", @user.id, @profile_user.id])
      @sms_user_notification = SmsUserNotification.find(:first, :conditions => ["user_id = ? AND notifying_about = ?", @user.id, @profile_user.id])
    end
    @profile_setting = @profile_user.setting
    if @profile_setting.use_background_image == false
      @theme = @profile_setting.theme
    end
  end
end