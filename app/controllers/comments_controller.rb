class CommentsController < ApplicationController
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
    @blogcast = Blogcast.find(params[:blogcast_id]) 
    @comment = Comment.new(params[:comment])
    @comment.user_id = @user.id
    @comment.blogcast_id = @blogcast.id
    if !@comment.save
      respond_to do |format|
        format.js {@error = "Unable to save comment"; render :action => "error"}
        format.html {flash[:error] = "Unable to save comment"; redirect_to :back}
        format.xml {render :xml => @comment.errors.to_xml, :status => :unprocessable_entity}
        format.json {render :json => @comment.errors.to_json, :status => :unprocessable_entity}
      end
      return
    end
    begin
      thrift_user = Thrift::User.new
      if @user.instance_of?(BlogcastrUser)
        thrift_user.username = @user.username
        thrift_user.url = profile_path :username => @user.username
        thrift_user.avatar_url = @user.setting.avatar.url :small
      else
        thrift_user.username = @user.get_username
        thrift_user.url = @user.get_url
        thrift_user.avatar_url = @user.get_avatar_url :small
      end
      thrift_comment = Thrift::Comment.new
      thrift_comment.id = @comment.id
      thrift_comment.timestamp = @comment.created_at.to_i
      thrift_comment.medium = @comment.from
      thrift_comment.text = @comment.text
      jid = params[:jid]
      #MVR - send to ejabberd
      #err = thrift_client.send_comment_to_muc_occupant("Blogcast." + @blogcast.id.to_s + "@conference." + HOST + "/dashboard", jid, thrift_user, thrift_comment)
      thrift_client_close
    rescue
      @comment.errors.add_to_base "Unable to send comment to muc room"
      @comment.destroy
      respond_to do |format|
        format.js {@error = "Unable to send comment to muc room"; render :action => "error"}
        format.html {flash[:error] = "Unable to send comment to muc room"; redirect_to :bacl}
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
