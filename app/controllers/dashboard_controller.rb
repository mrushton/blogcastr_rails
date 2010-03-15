class DashboardController < ApplicationController
  before_filter :authenticate
  before_filter :set_time_zone

  def show
    @user = current_user
    #MVR - find blogcast if it exists
    begin
      @blogcast = @user.blogcasts.find(params[:blogcast_id])
    rescue 
      render :file => "public/404.html", :layout => false, :status => 404
      return
    end
    @text_post = TextPost.new(:from => "Web")
    @image_post = ImagePost.new(:from => "Web")
    @audio_post = AudioPost.new(:from => "Web")
    #MVR - post stream 
    @posts = @blogcast.posts.find(:all, :order => "created_at DESC") 
    @num_posts = @posts.size
    #MVR - comment stream 
    @comments = Comment.find_all_by_blogcast_id(@blogcast.id, :order => "created_at DESC")
    @num_comments = @comments.size
    @likes = User.find_by_sql(["SELECT users.* FROM likes, users WHERE likes.blogcast_id = ? AND likes.user_id = users.id LIMIT 30", @blogcast.id])
    @num_likes = @blogcast.likes.count 
  end
end
