class CommentPostsController < ApplicationController
  #MVR - needed to work around CSRF for REST api
  #TODO: add CSRF before filter for standard authentication only, other option is to modify Rails to bypass CSRF for certain user agents
  skip_before_filter :verify_authenticity_token
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
    #AS DESIGNED: only need to search on comment id to see if it has already been reposted
    if !@comment.post.nil?
      respond_to do |format|
        format.js { @error = "Oops! Comment has already been posted."; render :action => "error" }
        format.html { flash[:error] = "Oops! Comment has already been posted"; redirect_to :back }
        #TODO: fix xml and json support
        #format.xml { render :xml => @comment_post.errors.to_xml, :status => :unprocessable_entity }
        #format.json { render :json => @comment_post.errors.to_json, :status => :unprocessable_entity }
      end
      return
    end
    #TODO: param format seems non-standard (i.e. should be comment_post[from])
    @comment_post = CommentPost.create(:user_id => @user.id, :blogcast_id => @blogcast.id, :from => params[:from], :comment_id => @comment.id)
    @comment_user = @comment.user
    begin
      thrift_user = Thrift::User.new
      thrift_user.id = @user.id
      #MVR - only Blogcast users can make posts
      thrift_user.type = "BlogcastrUser" 
      thrift_user.username = @user.username
      thrift_user.url = profile_path :username => @user.username
      thrift_user.avatar_url = @user.setting.avatar.url :medium
      thrift_comment_post = Thrift::CommentPost.new
      thrift_comment_post.id = @comment_post.id
      thrift_comment_post.created_at = @comment_post.created_at.xmlschema
      thrift_comment_post.from = @comment_post.from
      thrift_comment = Thrift::Comment.new
      thrift_comment.id = @comment.id
      thrift_comment.created_at = @comment.created_at.xmlschema
      thrift_comment.from = @comment.from
      thrift_comment.text = @comment.text
      thrift_comment_user = Thrift::User.new
      thrift_comment_user.id = @comment_user.id
      thrift_comment_user.type = @comment_user.class.to_s 
      if @comment_user.instance_of?(BlogcastrUser)
        thrift_comment_user.username = @comment_user.username
        thrift_comment_user.url = profile_path :username => @comment_user.username
        thrift_comment_user.avatar_url = @comment_user.setting.avatar.url :original
      elsif @comment_user.instance_of?(FacebookUser)
        thrift_comment_user.username = @comment_user.setting.full_name
        thrift_comment_user.url = @comment_user.facebook_link 
        thrift_comment_user.avatar_url = @comment_user.setting.avatar.url :original
      elsif @comment_user.instance_of?(TwitterUser)
        thrift_comment_user.username = "@" + @comment_user.username
        thrift_comment_user.url = "http://twitter.com/" + @comment_user.username 
        thrift_comment_user.avatar_url = @comment_user.setting.avatar.url :original
      end
      #MVR - send comment post to blogcast 
      err = thrift_client.send_comment_post_to_muc_room(@user.username, HOST, "Blogcast."+@blogcast.id.to_s, thrift_user, thrift_comment_post, thrift_comment_user, thrift_comment)
      thrift_client_close
    rescue
      @comment_post.errors.add_to_base "Oops! Unable to send comment post to blogcast"
      respond_to do |format|
        format.js { @error = "Oops! Unable to send comment post to blogcast."; render :action => "error" }
        format.html { flash[:error] = "Oops! Unable to send comment post to blogcast"; redirect_to :back }
        format.xml { render :xml => @comment_post.errors.to_xml, :status => :unprocessable_entity }
        #TODO: fix json support
        format.json { render :json => @comment_post.errors.to_json, :status => :unprocessable_entity }
      end
      return
    end
    respond_to do |format|
      format.js
      format.html {flash[:notice] = "Text post posted successfully"; redirect_to :back}
      format.xml {render :xml => @comment_post}
      format.json {render :json => @comment_post}
    end
  end
end
