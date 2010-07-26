class HomeController < ApplicationController
  before_filter :authenticate
  before_filter :set_time_zone

  def index
    @user = current_user
    #MVR - upcoming blogcasts
    @upcoming_blogcasts = @user.blogcasts.find(:all, :conditions => ["starting_at > ?", Time.zone.now], :limit => 3)
    @num_upcoming_blogcasts = Blogcast.count(:conditions => ["user_id = ? AND starting_at > ?", @user.id, Time.zone.now])
    #MVR - recent blogcasts
    @recent_blogcasts = @user.blogcasts.find(:all, :conditions => ["starting_at < ? AND starting_at > ?", Time.zone.now, 1.month.ago], :limit => 3)
    @num_recent_blogcasts = Blogcast.count(:conditions => ["user_id = ? AND starting_at < ? AND starting_at > ?", @user.id, Time.zone.now, 1.month.ago])
    #MVR - blogcasts
    @num_blogcasts = @user.blogcasts.count
    #MVR - subscriptions
    @subscriptions = User.find_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id LIMIT 30", @user.id])
    @num_subscriptions = @user.subscriptions.count
    #MVR - subscribers
    @subscribers = User.find_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.subscribed_to = ? AND subscriptions.user_id = users.id LIMIT 30", @user.id])
    @num_subscribers = @user.subscribers.count
    #MVR - posts
    @num_posts = @user.posts.count
    #MVR - reposts
    @num_reposts = Repost.count(:conditions => {:user_id => @user.id})
    #MVR - comments
    @num_comments = @user.comments.count 
    #MVR - subscription blogcasts
    #TODO: don't use the *_by_sql methods
    @num_upcoming_subscription_blogcasts = Blogcast.count_by_sql(["SELECT count(*) FROM subscriptions, users, blogcasts WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id AND users.id = blogcasts.user_id AND blogcasts.starting_at > ?", @user.id, Time.zone.now])
    @upcoming_subscription_blogcasts = Blogcast.find_by_sql(["SELECT blogcasts.* FROM subscriptions, users, blogcasts WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id AND users.id = blogcasts.user_id AND blogcasts.starting_at > ? ORDER BY blogcasts.starting_at LIMIT 3", @user.id, Time.zone.now])
    @num_recent_subscription_blogcasts = Blogcast.count_by_sql(["SELECT count(*) FROM subscriptions, users, blogcasts WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id AND users.id = blogcasts.user_id AND blogcasts.starting_at < ?", @user.id, Time.zone.now])
    @recent_subscription_blogcasts = Blogcast.find_by_sql(["SELECT blogcasts.* FROM subscriptions, users, blogcasts WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id AND users.id = blogcasts.user_id AND blogcasts.starting_at < ? ORDER BY blogcasts.starting_at DESC LIMIT 3", @user.id, Time.zone.now])
    @blogcasts = @user.blogcasts
    @blogcast = Blogcast.new
    @user_username_possesive = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
  end

  def index_profile
    @user = current_user
    @profile_user = User.find_by_name(params[:username])
    if @profile_user.nil?
      #MVR - treat this as a 404 error
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
      return
    end
    if !@user.nil? && @user.id != @profile_user.id
      @subscription = @user.subscriptions.find(:first, :conditions => {:subscribed_to => @profile_user.id})
    end
    #MVR - upcoming blogcasts
    @upcoming_blogcasts = @profile_user.blogcasts.find(:all, :conditions => ["starting_at > ?", Time.zone.now], :limit => 3)
    @num_upcoming_blogcasts = Blogcast.count(:conditions => ["user_id = ? AND starting_at > ?", @profile_user.id, Time.zone.now])
    #MVR - recent blogcasts
    @recent_blogcasts = @profile_user.blogcasts.find(:all, :conditions => ["starting_at < ? AND starting_at > ?", Time.zone.now, 1.month.ago], :limit => 3)
    @num_recent_blogcasts = Blogcast.count(:conditions => ["user_id = ? AND starting_at < ? AND starting_at > ?", @profile_user.id, Time.zone.now, 1.month.ago])
    #MVR - blogcasts
    @num_blogcasts = @profile_user.blogcasts.count
    #MVR - subscriptions
    @subscriptions = User.find_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id LIMIT 30", @profile_user.id])
    @num_subscriptions = @profile_user.subscriptions.count
    #MVR - subscribers
    @subscribers = User.find_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.subscribed_to = ? AND subscriptions.user_id = users.id LIMIT 30", @profile_user.id])
    @num_subscribers = @profile_user.subscribers.count
    #MVR - posts
    @num_posts = @profile_user.posts.count
    #MVR - reposts
    @num_reposts = Repost.count(:conditions => {:user_id => @profile_user.id})
    #MVR - comments
    @num_comments = @profile_user.comments.count 
    #MVR - subscription blogcasts
    @upcoming_subscription_blogcasts = Blogcast.find_by_sql(["SELECT blogcasts.* FROM subscriptions, users, blogcasts WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id AND users.id = blogcasts.user_id AND blogcasts.starting_at > ? ORDER BY blogcasts.starting_at LIMIT 3", @profile_user.id, Time.zone.now])
    @recent_subscription_blogcasts = Blogcast.find_by_sql(["SELECT blogcasts.* FROM subscriptions, users, blogcasts WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id AND users.id = blogcasts.user_id AND blogcasts.starting_at < ? ORDER BY blogcasts.starting_at DESC LIMIT 3", @profile_user.id, Time.zone.now])
  end
end
