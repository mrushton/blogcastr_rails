class CommentPostsController < ApplicationController
  before_filter :authenticate

  def create
    #MVR - no need to verify user or blog
    @user = current_user
    @blogcast = @user.blogcast
    @comment_post = CommentPost.create(:blogcast_id => @blogcast.id, :from => params[:from], :comment_id => params[:comment_id])
    @comment = @comment_post.comment
    @comment_user = @comment.user
    thrift_comment_post_user = Thrift::User.new
    thrift_comment_post_user.name = @user.get_user_name
    thrift_comment_post_user.account = @user.class.to_s 
    thrift_comment_post_user.url = @user.get_user_url
    thrift_comment_post_user.avatar_url = @user.get_user_avatar_url :medium
    thrift_comment_post = Thrift::CommentPost.new
    thrift_comment_post.id = @comment_post.id
    thrift_comment_post.timestamp = @comment_post.created_at.to_i
    thrift_comment_post.medium = @comment_post.from
    thrift_comment_user = Thrift::User.new
    thrift_comment_user.name = @comment_user.get_user_name
    thrift_comment_user.account = @comment_user.class.to_s 
    thrift_comment_user.url = @comment_user.get_user_url
    thrift_comment_user.avatar_url = @comment_user.get_user_avatar_url :medium
    if @comment.instance_of?(TextComment)
      thrift_text_comment = Thrift::TextComment.new
      thrift_text_comment.id = @comment.id
      thrift_text_comment.timestamp = @comment.created_at.to_i
      thrift_text_comment.medium = @comment.from
      thrift_text_comment.text = @comment.text
      #MVR - send text comment post to muc room and pubsub node
      err = thrift_client.send_comment_post_to_muc_room(@user.name, @user.name + ".blog", thrift_comment_post_user, thrift_comment_post, thrift_comment_user, thrift_text_comment)
    #err = thrift_client.publish_text_post_to_pubsub_node(@user.login, "/home/blogcastr.com/" + @user.login + "/blog", thriftTextPost)
      thrift_client_close
    elsif @comment.instance_of?(ImageComment)
      #TODO - add image comments
    end
    #TODO: gracefully handle errors or no javascript support
    render :nothing => true
  end
end
