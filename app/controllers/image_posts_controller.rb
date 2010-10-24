class ImagePostsController < ApplicationController
  #MVR - needed to work around CSRF for REST api
  #TODO: add CSRF before filter for standard authentication only, other option is to modify Rails to bypass CSRF for certain user agents
  skip_before_filter :verify_authenticity_token
  before_filter :set_time_zone
  before_filter do |controller|
    if controller.request.format.html?
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
    @image_post = ImagePost.new(params[:image_post])
    @image_post.user_id = @user.id
    @image_post.blogcast_id = @blogcast.id
    if !@image_post.save
      respond_to do |format|
        format.js {@error = "Unable to save image post"; render :action => "error"}
        format.html {flash[:error] = "Unable to save image post"; redirect_to :back}
        format.xml {render :xml => @image_post.errors, :status => :unprocessable_entity}
        format.json {render :json => @image_post.errors, :status => :unprocessable_entity}
      end
      return
    end
    begin
      thrift_user = Thrift::User.new
      thrift_user.username = @user.username
      thrift_user.account = "Blogcastr"
      thrift_user.url = profile_path :username => @user.username
      thrift_user.avatar_url = @user.setting.avatar.url(:medium)
      thrift_image_post = Thrift::ImagePost.new
      thrift_image_post.id = @image_post.id
      thrift_image_post.date = @image_post.created_at.strftime("%b %d, %Y %I:%M %p %Z").gsub(/ 0/, ' ')
      thrift_image_post.timestamp = @image_post.created_at.to_i
      thrift_image_post.medium = @image_post.from
      thrift_image_post.image_url = @image_post.image.url(:default)
      if !@image_post.text.blank?
        thrift_image_post.text = @image_post.text
      end
      #MVR - send image post to muc room
      err = thrift_client.send_image_post_to_muc_room(@user.username, HOST, "Blogcast."+@blogcast.id.to_s, thrift_user, thrift_image_post)
      thrift_client_close
    rescue
      @image_post.errors.add_to_base "Unable to send image post to muc room"
      @image_post.destroy
      respond_to do |format|
        format.js {@error = "Unable to send image post to muc room"; render :action => "error"}
        format.html {flash[:error] = "Unable to send text post to muc room"; redirect_to :back}
        format.xml {render :xml => @text_post.errors, :status => :unprocessable_entity}
        #TODO: fix json support
        format.json {render :json => @text_post.errors, :status => :unprocessable_entity}
      end
      return
    end
    respond_to do |format|
      format.js
      format.html {flash[:success] = "Image post posted successfully"; redirect_to :back}
      #TODO: add http Location header back once posts have their own url
      format.xml {render :xml =>@image_post, :status => :created}
      format.json {render :json => @image_post, :status => :created}
    end
  end

  def destroy
    if params[:authentication_token].nil?
      @user = current_user
    else 
      @user = rest_current_user
    end
    #MVR - find image post
    #AS DESIGNED: do not bother with what type it is 
    @image_post = @user.posts.find(params[:id]) 
    if @image_post.nil?
      respond_to do |format|
        format.js {@error = "Unable to find image post"; render :action => "error"}
        format.html {flash[:error] = "Unable to find image post"; redirect_to :back}
        #TODO: fix xml and json support
        format.xml {render :xml => @image_post.errors, :status => :unprocessable_entity}
        format.json {render :json => @image_post.errors, :status => :unprocessable_entity}
      end
      return
    end
    @image_post.destroy
    respond_to do |format|
      format.js
      format.html {flash[:notice] = "Image post deleted successfully"; redirect_to :back}
      format.xml {render :xml => @image_post}
      format.json {render :json => @image_post}
    end
  end
end
