class DashboardController < ApplicationController
  before_filter :authenticate

  def index
    @user = current_user
    @blogcast = @user.blogcast 
    @text_post = TextPost.new(:from => "Web")
    @image_post = ImagePost.new(:from => "Web")
    #MVR - retrieve blog comments in reverse chronological order
    @comments = Comment.find_all_by_blogcast_id(@blogcast.id, :order => "created_at DESC")
    #MVR - get all posts from subscriptions
    #TODO: limit to 10 and page
    @posts = Post.find_by_sql(["SELECT * FROM subscriptions, posts WHERE subscriptions.user_id = ? AND subscriptions.blogcast_id = posts.blogcast_id ORDER BY posts.created_at DESC", @user.id]);
  end
end
