class ImagePostsController < ApplicationController
  before_filter :authenticate

  def create
    #MVR - no need to verify user or blog
    @user = current_user
    @blogcast = @user.blogcasts.find(params[:blogcast_id]) 
    @image_post = ImagePost.new(params[:image_post])
    @image_post.blogcast_id = @blogcast.id
    @image_post.save
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
