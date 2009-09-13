class RepostsController < ApplicationController
  before_filter :authenticate

  def create
    #MVR - no need to verify user or blog
    @user = current_user
    @blogcast = @user.blogcast
    @repost = Repost.create(:blogcast_id => @blogcast.id, :from => params[:from], :parent_id => params[:post_id])
    
 #   @textPost = TextPost.new(params[:text_post])
 #   @textPost.blog_id = @blog.id
 #   @textPost.save
 #   textPostMessage = TextPostMessage.new
 #   textPostMessage.id = @textPost.id
 #   textPostMessage.date = @textPost.created_at.to_s
 #   textPostMessage.text = @textPost.text
    #MVR - send text post to muc room and pubsub node
 #   err = thrift_client.send_text_post_to_muc_room(@user.login, @blog.name + ".blog", textPostMessage)
 #   err = thrift_client.publish_text_post_to_pubsub_node(@user.login, "/home/blogcastr.com/" + @user.login + "/blog", textPostMessage)
  #  thrift_client_close
    #TODO: gracefully handle errors or no javascript support
    render :nothing => true
  end
end
