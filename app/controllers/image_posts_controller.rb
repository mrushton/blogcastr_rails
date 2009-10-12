class ImagePostsController < ApplicationController
  before_filter do |controller|
    if controller.request.format.html?
      controller.authenticate
    else 
      controller.rest_authenticate
    end
  end

  def create
    if request.format.html?
      @user = current_user
    else 
      @user = rest_current_user
    end
    @blogcast = @user.blogcasts.find(params[:blogcast_id]) 
    @image_post = ImagePost.new(params[:image_post])
    @image_post.blogcast_id = @blogcast.id
    begin
      @image_post.save
    rescue ActiveRecord::StatementInvalid => error
      respond_to do |format|
        format.html {render :file => "public/404.html", :layout => false, :status => 404}
        format.xml {render :xml => "<errors><error>#{error.message}</error></errors>", :status => :unprocessable_entity}
        format.json {render :json => "[[\"#{error.message}\"]]", :status => :unprocessable_entity}
      end
      return
    end
    thrift_user = Thrift::User.new
    thrift_user.name = @user.name
    thrift_user.account = "Blogcastr"
    thrift_user.url = profile_path :username => @user.name
    thrift_user.avatar_url = @user.setting.avatar.url(:medium)
    thrift_image_post = Thrift::ImagePost.new
    thrift_image_post.id = @image_post.id
    thrift_image_post.timestamp = @image_post.created_at.to_i
    thrift_image_post.medium = @image_post.from
    thrift_image_post.image_url = @image_post.image.url(:default)
    #MVR - send image post to muc room and pubsub node
    err = thrift_client.send_image_post_to_muc_room(@user.name, @user.name + ".blog", thrift_user, thrift_image_post)
    #err = thrift_client.publish_image_post_to_pubsub_node(@user.login, "/home/blogcastr.com/" + @user.login + "/blog", imagePostMessage)
    thrift_client_close
    redirect_to :back
  end
end
