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
    #MVR - save the original file for post processing
    if !params[:audio_post].nil? && !params[:audio_post][:audio].nil?
      audio_file = params[:audio_post][:audio]
    else
      audio_file = nil
    end
    if audio_file.is_a?(Tempfile)
      #AS DESIGNED: don't use temp file because they get destroyed when the app terminates
      extension = File.extname(audio_file.original_filename)
      #AS DESIGNED: would like to use post id to keep it simple but paperclip deletes the file by the time the object is saved
      audio_post_process_file_name = sprintf("/tmp/%s.%d.%d.%d%s", File.basename(audio_file.original_filename, extension), $$, Time.now, rand(4294967296), extension)
      audio_post_process_file = File.new(audio_post_process_file_name, "wb+")
      buffer = ""
      while audio_file.read(8192, buffer) do
        audio_post_process_file.write(buffer)
      end
      audio_post_process_file.close
      audio_file.rewind
    else
      audio_post_process_file_name = nil 
    end
    @audio_post = AudioPost.new(params[:audio_post])
    @audio_post.user_id = @user.id
    @audio_post.blogcast_id = @blogcast.id
    @audio_post.audio_post_process_file_name = audio_post_process_file_name
    if !@audio_post.save
      #MVR - remove post processing file
      if !audio_post_process_file_name.nil?
        FileUtils.rm_f(audio_post_process_file_name)
      end
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
      #MVR - remove post processing file
      if !audio_post_process_file_name.nil?
        FileUtils.rm_f(audio_post_process_file_name)
      end
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
