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
    @text_post = TextPost.new(:from => "Web", :text => "Enter text here...")
    @image_post = ImagePost.new(:from => "Web", :text => "Enter optional caption here...")
    @audio_post = AudioPost.new(:from => "Web")
    begin
      #TODO: these rooms are created using an uppercase B but this needs to be lowercase
      @num_viewers = thrift_client.get_num_muc_room_occupants("blogcast." + @blogcast.id.to_s) + 1
      thrift_client_close
    rescue
      @num_viewers = 1 
    end
    #MVR - post stream 
    @posts = @blogcast.posts.find(:all, :order => "created_at DESC") 
    @num_posts = @posts.size
    #MVR - comment stream 
    @comments = Comment.find_all_by_blogcast_id(@blogcast.id, :order => "created_at DESC")
    #MVR - stats
    @num_comments = @comments.size
    @num_likes = @blogcast.likes.count 
    @num_views = @blogcast.views.count
  end
end
