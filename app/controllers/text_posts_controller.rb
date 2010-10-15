class TextPostsController < ApplicationController
  #MVR - needed to work around CSRF for REST api
  #TODO: add CSRF before filter for standard authentication only, other option is to modify Rails to bypass CSRF for certain user agents
  skip_before_filter :verify_authenticity_token
  before_filter :set_time_zone
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
    @text_post = TextPost.new(params[:text_post])
    #MVR - find blogcast
    @blogcast = @user.blogcasts.find(params[:blogcast_id]) 
    if @blogcast.nil?
      @text_post.valid?
      @text_post.errors.add_to_base "Invalid blogcast id"
      respond_to do |format|
        format.js {@error = "Invalid blogcast id"; render :action => "error"}
        format.html {flash[:error] = "Invalid blogcast id"; redirect_to :back}
        format.xml {render :xml => @text_post.errors.to_xml, :status => :unprocessable_entity}
        format.json {render :json => @text_post.errors.to_json, :status => :unprocessable_entity}
      end
      return
    end
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
      thrift_user.username = @user.username
      thrift_user.account = "Blogcastr"
      thrift_user.url = profile_path :username => @user.username
      thrift_user.avatar_url = @user.setting.avatar.url(:medium)
      thrift_text_post = Thrift::TextPost.new
      thrift_text_post.id = @text_post.id
      thrift_text_post.date = @text_post.created_at.strftime("%b %d, %Y %I:%M %p %Z").gsub(/ 0/, ' ')
      thrift_text_post.timestamp = @text_post.created_at.to_i
      thrift_text_post.medium = @text_post.from
      thrift_text_post.text = @text_post.text
      #MVR - send text post to muc room
      err = thrift_client.send_text_post_to_muc_room(@user.username, HOST, "Blogcast."+@blogcast.id.to_s, thrift_user, thrift_text_post)
      thrift_client_close
    rescue
      @text_post.errors.add_to_base "Unable to send text post to muc room"
      @text_post.destroy
      respond_to do |format|
        format.js {@error = "Unable to send text post to muc room"; render :action => "error"}
        format.html {flash[:error] = "Unable to send text post to muc room"; redirect_to :back}
        format.xml {render :xml => @text_post.errors, :status => :unprocessable_entity}
        #TODO: fix json support
        format.json {render :json => @text_post.errors, :status => :unprocessable_entity}
      end
      return
    end
    respond_to do |format|
      format.js
      format.html {flash[:notice] = "Text post posted successfully"; redirect_to :back}
      #TODO: add http Location header back once posts have their own url
      format.xml {render :xml => @text_post, :status => :created}
      format.json {render :json => @text_post, :status => :created}
    end
  end

  def destroy
    if params[:authentication_token].nil?
      @user = current_user
    else 
      @user = rest_current_user
    end
    #MVR - find post
    #AS DESIGNED: do not bother with what type it is 
    @post = @user.posts.find(params[:id]) 
    if @post.nil?
      respond_to do |format|
        format.js {@error = "Unable to find text post"; render :action => "error"}
        format.html {flash[:error] = "Unable to fine text post"; redirect_to :back}
        #TODO: fix xml and json support
        format.xml {render :xml => @post.errors, :status => :unprocessable_entity}
        format.json {render :json => @post.errors, :status => :unprocessable_entity}
      end
      return
    end
    @post.destroy
    respond_to do |format|
      format.js
      format.html {flash[:notice] = "Text post deleted successfully"; redirect_to :back}
      format.xml {render :xml => @text_post}
      format.json {render :json => @text_post}
    end
  end
end
