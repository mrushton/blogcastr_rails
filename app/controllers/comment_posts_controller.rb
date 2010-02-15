class CommentPostsController < ApplicationController
  before_filter do |controller|
    if controller.params[:authentication_token].nil?
      controller.authenticate
    else 
      controller.rest_authenticate
    end
  end

  def create
    if params[:authentication_token].nil?
      @user = current_user
    else 
      @user = rest_current_user
    end
    #MVR - find blogcast
    @blogcast = @user.blogcasts.find(params[:blogcast_id]) 
    if @blogcast.nil?
      respond_to do |format|
        format.js {@error = "Unable to find blogcast"; render :action => "error"}
        format.html {flash[:error] = "Unable to find blogcast"; redirect_to :back}
        #TODO: handle xml and json
        format.xml {render :xml => "ERROR", :status => :unprocessable_entity}
        format.json {render :json => "ERROR", :status => :unprocessable_entity}
      end
      return
    end
    #MVR - find comment
    @comment = Comment.find(params[:comment_id])
    if @comment.nil?
      respond_to do |format|
        format.js {@error = "Comment does not exist"; render :action => "error"}
        format.html {flash[:error] = "Comment does not exist"; redirect_to :back}
        #TODO: handle xml and json
        format.xml {render :xml => "ERROR", :status => :unprocessable_entity}
        format.json {render :json => "ERROR", :status => :unprocessable_entity}
      end
      return
    end
    @comment_post = CommentPost.create(:user_id => @user.id, :blogcast_id => @blogcast.id, :from => params[:from], :comment_id => @comment.id)
    @comment_user = @comment.user
    begin
      thrift_user = Thrift::User.new
      thrift_user.account = @user.class.to_s 
      if @user.instance_of?(BlogcastrUser)
        thrift_user.username = @user.username
        thrift_user.url = profile_path :username => @user.username
        thrift_user.avatar_url = @user.setting.avatar.url :small
      else
        thrift_user.username = @user.get_username
        thrift_user.url = @user.get_url
        thrift_user.avatar_url = @user.get_avatar_url :small
      end
      thrift_comment_post = Thrift::CommentPost.new
      thrift_comment_post.id = @comment_post.id
      thrift_comment_post.date = @comment_post.created_at.strftime("%b %d, %Y %I:%M %p %Z").gsub(/ 0/, ' ')
      thrift_comment_post.timestamp = @comment_post.created_at.to_i
      thrift_comment_post.medium = @comment_post.from
      thrift_comment = Thrift::Comment.new
      thrift_comment.id = @comment.id
      thrift_comment.date = @comment.created_at.strftime("%b %d, %Y %I:%M %p %Z").gsub(/ 0/, ' ')
      thrift_comment.timestamp = @comment.created_at.to_i
      thrift_comment.medium = @comment.from
      thrift_comment.text = @comment.text
      thrift_comment_user = Thrift::User.new
      thrift_comment_user.account = @comment_user.class.to_s 
      if @comment_user.instance_of?(BlogcastrUser)
        thrift_comment_user.username = @comment_user.username
        thrift_comment_user.url = profile_path :username => @comment_user.username
        thrift_comment_user.avatar_url = @comment_user.setting.avatar.url :small
      else
        thrift_comment_user.username = @comment_user.get_username
        thrift_comment_user.url = @comment_user.get_url
        thrift_comment_user.avatar_url = @comment_user.get_avatar_url :small
      end
      #MVR - send comment post to blogcast 
      err = thrift_client.send_comment_post_to_muc_room(@user.username, HOST, "Blogcast."+@blogcast.id.to_s, thrift_user, thrift_comment_post, thrift_comment_user, thrift_comment)
      thrift_client_close
    rescue
      @comment_post.errors.add_to_base "Unable to send comment post to blogcast"
      @comment_post.destroy
      respond_to do |format|
        format.js {@error = "Unable to send comment post to blogcast."; render :action => "error"}
        format.html {flash[:error] = "Unable to send comment post to blogcast"; redirect_to :back}
        format.xml {render :xml => @comment.errors.to_xml, :status => :unprocessable_entity}
        #TODO: fix json support
        format.json {render :json => @comment.errors.to_json, :status => :unprocessable_entity}
      end
      return
    end
    respond_to do |format|
      format.js
      format.html {flash[:notice] = "Text post posted successfully"; redirect_to :back}
      format.xml {render :xml => @text_post.to_xml, :status => :created, :location => @text_post}
      format.json {render :json => @text_post.to_json, :status => :created, :location => @text_post}
    end
  end
end
