class DashboardController < ApplicationController
  before_filter :authenticate
  before_filter :set_time_zone

  def show
    @user = current_user
    #@blogcast = @user.blogcasts.find(:first, :conditions => ["year = ? AND month = ? AND day = ? AND link_title = ?", params[:year], params[:month], params[:day], params[:title]])
    @blogcast = @user.blogcasts.find(params[:blogcast_id])
    @text_post = TextPost.new(:from => "Web")
    @image_post = ImagePost.new(:from => "Web")
    #MVR - blogcast stream
    @comments = Comment.find_all_by_blogcast_id(@blogcast.id, :order => "created_at DESC")
    #MVR - subscription stream
    #TODO: limit to 10 and page
    @posts = Post.find_by_sql(["SELECT * FROM subscriptions, blogcasts, posts WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = blogcasts.user_id AND blogcasts.id = posts.blogcast_id ORDER BY posts.created_at DESC", @user.id]);




  end

  def index
    @user = current_user
    #MVR - subscription blogcasts
    @upcoming_subscription_blogcasts = Blogcast.find_by_sql(["SELECT blogcasts.* FROM subscriptions, users, blogcasts WHERE subscriptions.user_id = ? AND subscriptions.subscription_user_id = users.id AND users.id = blogcasts.user_id AND blogcasts.starting_at > ? ORDER BY blogcasts.starting_at LIMIT 3", @user.id, Time.zone.now])
    @recent_subscription_blogcasts = Blogcast.find_by_sql(["SELECT blogcasts.* FROM subscriptions, users, blogcasts WHERE subscriptions.user_id = ? AND subscriptions.subscription_user_id = users.id AND users.id = blogcasts.user_id AND blogcasts.starting_at < ? ORDER BY blogcasts.starting_at DESC LIMIT 3", @user.id, Time.zone.now])
    @blogcasts = @user.blogcasts
    

#    @text_post = TextPost.new(:from => "Web")
#    @image_post = ImagePost.new(:from => "Web")
    #MVR - retrieve blog comments in reverse chronological order
#    @comments = Comment.find_all_by_blogcast_id(@blogcast.id, :order => "created_at DESC")
    #MVR - get all posts from subscriptions
    #TODO: limit to 10 and page
#    @posts = Post.find_by_sql(["SELECT * FROM subscriptions, posts WHERE subscriptions.user_id = ? AND subscriptions.blogcast_id = posts.blogcast_id ORDER BY posts.created_at DESC", @user.id]);
  end
end
