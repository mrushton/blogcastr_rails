class ProfileController < ApplicationController
  before_filter :set_cache_headers
  before_filter :set_time_zone

  def index
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
    @profile_user_name_possesive = @profile_user.name + (@profile_user.name =~ /.*s$/ ? "'":"'s")
    @profile_user_name_possesive_escaped = @profile_user_name_possesive.gsub(/'/,"\\\\\'")
  end
end
