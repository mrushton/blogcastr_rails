class TextCommentsController < ApplicationController
  #TODO: add Facebook/Twitter support
  #TODO: better error handling 
  before_filter :authenticate

  def create
    #MVR - no need to verify user
    @user = current_user
    @blogcast = Blogcast.find(params[:blogcast_id])
    @text_comment = TextComment.new(params[:text_comment])
    @text_comment.user_id = @user.id
    @text_comment.blogcast_id = @blogcast.id
    @text_comment.save
    thrift_user = Thrift::User.new
    thrift_user.name = @user.name
    #TODO - support Facebook and Twitter
    thrift_user.account = "Blogcastr"
    thrift_user.url = blogcast_path :username => @user.name
    thrift_user.avatar_url = @user.setting.avatar.url(:medium)  
    thrift_text_comment = Thrift::TextComment.new
    thrift_text_comment.id = @text_comment.id
    thrift_text_comment.timestamp = @text_comment.created_at.to_i
    thrift_text_comment.medium = @text_comment.from
    thrift_text_comment.text = @text_comment.text
    resource = params[:jid_resource]
    #MVR - send to ejabberd
#    err = thrift_client.send_text_comment_to_muc_occupant(@blog.name + ".blog@conference.blogcastr.com/dashboard", @user.name + "@blogcastr.com/" + resource, thrift_user, thrift_text_comment)
 #   thrift_client_close
    #TODO: gracefully handle errors or no javascript support
    render :nothing => true
  end
end
