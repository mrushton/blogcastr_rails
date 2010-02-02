class TextPostsController < ApplicationController
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
    @text_post = TextPost.new(params[:text_post])
    @text_post.blogcast_id = @blogcast.id
    @text_post.user_id = @user.id
    if !@text_post.save
      respond_to do |format|
        format.js {@error = "Unable to save text post"; render :action => "error"}
        format.html {flash[:error] = "Unable to save text post"; redirect_to :back}
        format.xml {render :xml => @text_post.errors.to_xml, :status => :unprocessable_entity}
        format.json {render :json => @text_post.errors.to_json, :status => :unprocessable_entity}
      end
      return
    end
    begin
      thrift_user = Thrift::User.new
      thrift_user.name = @user.username
      thrift_user.account = "Blogcastr"
      thrift_user.url = profile_path :username => @user.username
      thrift_user.avatar_url = @user.setting.avatar.url(:medium)
      thrift_text_post = Thrift::TextPost.new
      thrift_text_post.id = @text_post.id
      thrift_text_post.timestamp = @text_post.created_at.to_i
      thrift_text_post.medium = @text_post.from
      thrift_text_post.text = @text_post.text
      #MVR - send text post to muc room
      #err = thrift_client.send_text_post_to_muc_room(@user.name, HOST, "Blogcast."+@blogcast.id.to_s, thrift_user, thrift_text_post)
      thrift_client_close
    rescue
      @text_post.errors.add_to_base "Unable to send text post to muc room"
      @text_post.destroy
      respond_to do |format|
        format.js {@error = "Unable to send text post to muc room"; render :action => "error"}
        format.html {flash[:error] = "Unable to send text post to muc room"; redirect_to :bacl}
        format.xml {render :xml => @text_post.errors.to_xml, :status => :unprocessable_entity}
        #TODO: fix json support
        format.json {render :json => @text_post.errors.to_json, :status => :unprocessable_entity}
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
