class HomeController < ApplicationController
  before_filter :authenticate
  before_filter :set_time_zone

  def show 
    @user = current_user
    #MVR - stats
    @num_blogcasts = @user.blogcasts.count
    @num_subscriptions = @user.subscriptions.count
    @subscriptions = User.find_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id LIMIT 30", @user.id])
    @num_subscribers = @user.subscribers.count
    @subscribers = User.find_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.subscribed_to = ? AND subscriptions.user_id = users.id LIMIT 30", @user.id])
    @num_posts = @user.posts.count
    @num_comments = @user.comments.count 
    @num_likes = @user.likes.count 
    #MVR - subscription blogcasts
    #TODO: don't use the *_by_sql methods
    @upcoming_subscription_blogcasts = Blogcast.find_by_sql(["SELECT blogcasts.* FROM subscriptions, users, blogcasts WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id AND users.id = blogcasts.user_id AND blogcasts.starting_at > ? ORDER BY blogcasts.starting_at LIMIT 2", @user.id, Time.zone.now])
    @past_subscription_blogcasts = Blogcast.find_by_sql(["SELECT blogcasts.* FROM subscriptions, users, blogcasts WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id AND users.id = blogcasts.user_id AND blogcasts.starting_at < ? ORDER BY blogcasts.starting_at DESC LIMIT 2", @user.id, Time.zone.now])
  end
end
