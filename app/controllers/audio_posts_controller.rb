class AudioPostsController < ApplicationController
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
    @audio_post = AudioPost.new(params[:audio_post])
    @audio_post.user_id = @user.id
    @audio_post.blogcast_id = @blogcast.id
    if !@audio_post.save
      respond_to do |format|
        format.js {@error = "Unable to save audio post"; render :action => "error"}
        format.html {flash[:error] = "Unable to save audio post"; redirect_to :back}
        format.xml {render :xml => @audio_post.errors.to_xml, :status => :unprocessable_entity}
        format.json {render :json => @audio_post.errors.to_json, :status => :unprocessable_entity}
      end
      return
    end
    begin
      thrift_user = Thrift::User.new
      thrift_user.username = @user.username
      thrift_user.account = "Blogcastr"
      thrift_user.url = profile_path :username => @user.username
      thrift_user.avatar_url = @user.setting.avatar.url(:small)
      thrift_audio_post = Thrift::AudioPost.new
      thrift_audio_post.id = @audio_post.id
      thrift_audio_post.date = @audio_post.created_at.strftime("%b %d, %Y %I:%M %p %Z").gsub(/ 0/, ' ')
      thrift_audio_post.timestamp = @audio_post.created_at.to_i
      thrift_audio_post.medium = @audio_post.from
      thrift_audio_post.audio_url = @audio_post.audio.url(:default)
      if (!@audio_post.text.blank?)
        thrift_audio_post.text = @audio_post.text
      end
      #MVR - send audio post to muc room
      err = thrift_client.send_audio_post_to_muc_room(@user.username, HOST, "Blogcast."+@blogcast.id.to_s, thrift_user, thrift_audio_post)
      thrift_client_close
    rescue
      @audio_post.errors.add_to_base "Unable to send audio post to muc room"
      @audio_post.destroy
      respond_to do |format|
        format.js {@error = "Unable to send audio post to muc room"; render :action => "error"}
        format.html {flash[:error] = "Unable to send audio post to muc room"; redirect_to :back}
        format.xml {render :xml => @audio_post.errors.to_xml, :status => :unprocessable_entity}
        #TODO: fix json support
        format.json {render :json => @audio_post.errors.to_json, :status => :unprocessable_entity}
      end
      return
    end
    respond_to do |format|
      format.js
      format.html {flash[:success] = "Audio posted successfully"; redirect_to :back}
      format.xml {render :xml => @audio_post.to_xml, :status => :created, :location => @audio_post}
      format.json {render :json => @audio_post.to_json, :status => :created, :location => @audio_post}
    end
  end
end
