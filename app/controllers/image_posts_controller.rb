class ImagePostsController < ApplicationController
  include HTTParty

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
  base_uri "https://graph.facebook.com"

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
    #MVR - save the image width and height using the identify command via Paperclip
    begin
      #TODO: performance of image processing is not optimal 
      file = params[:image_post][:image]
      geometry = Paperclip::Geometry.from_file(file)
      orientation = Paperclip.run("identify", "-verbose #{file.path} | grep -m 1 Orientation | awk '{ printf $2 }'");
      if (orientation == "Undefined" || orientation == "TopLeft" || orientation == "BottomRight") 
        @image_post.image_width = geometry.width
        @image_post.image_height = geometry.height
      else
        @image_post.image_width = geometry.height
        @image_post.image_height = geometry.width
      end
    rescue
      respond_to do |format|
        format.js { 
          @error = "Unable to process image post";
          render :action => "error"
        }
        format.html {
          flash[:error] = "Unable to process image post";
          redirect_to :back
        }
        format.xml { render :xml => "<errors><error>Unable to process image post</error></errors>", :status => :unprocessable_entity }
        format.json { render :json => "[[\"Unable to process image post\"]]", :status => :unprocessable_entity }
      end
      return
    end
    if !@image_post.save
      respond_to do |format|
        format.js { 
          @error = "Unable to save image post";
          render :action => "error"
        }
        format.html {
          flash[:error] = "Unable to save image post";
          redirect_to :back
        }
        format.xml { render :xml => @image_post.errors, :status => :unprocessable_entity }
        format.json { render :json => @image_post.errors, :status => :unprocessable_entity }
      end
      return
    end
    #MVR - create short url
    #TODO: probably should put this in after_create but need to work out the behavior of updating 
    bitly = Bitly.new(BITLY_LOGIN, BITLY_API_KEY)
    begin
      @image_post.short_url = bitly.shorten("http://" + HOST + "/" + @user.username + "/" + @blogcast.year.to_s + "/" + @blogcast.month.to_s + "/" + @blogcast.day.to_s + "/" + @blogcast.link_title + "/posts/" + @image_post.id.to_s)
    rescue BitlyError => e
      logger.error(e.message)
    end
    @image_post.save
    image_post_url = "http://" + HOST + "/" + @user.username + "/" + @blogcast.year.to_s + "/" + @blogcast.month.to_s + "/" + @blogcast.day.to_s + "/" + @blogcast.link_title + "/posts/" + @image_post.id.to_s
    begin
      thrift_user = Thrift::User.new
      thrift_user.id = @user.id
      thrift_user.type = "BlogcastrUser"
      thrift_user.username = @user.username
      thrift_user.url = profile_path :username => @user.username
      thrift_user.avatar_url = @user.setting.avatar.url(:original)
      thrift_image_post = Thrift::ImagePost.new
      thrift_image_post.id = @image_post.id
      thrift_image_post.created_at = @image_post.created_at.xmlschema
      thrift_image_post.from = @image_post.from
      thrift_image_post.url = image_post_url 
      thrift_image_post.short_url = @image_post.short_url
      #MVR - pass false to prevent updated timestamp from being included in the url 
      thrift_image_post.image_url = @image_post.image.url(:original, false)
      thrift_image_post.image_width = @image_post.image_width
      thrift_image_post.image_height = @image_post.image_height
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
        format.js { @error = "Unable to send image post to muc room"; render :action => "error" }
        format.html { flash[:error] = "Unable to send text post to muc room"; redirect_to :back }
        format.xml { render :xml => @image_post.errors, :status => :unprocessable_entity }
        #TODO: fix json support
        format.json { render :json => @image_post.errors, :status => :unprocessable_entity }
      end
      return
    end
    #MVR - Facebook share
    if (params['facebook_share'] == "1")
      if @user.facebook_access_token && @user.facebook_expires_at
        if @user.facebook_expires_at > Time.now
          begin
            #MVR - post to news feed
            query = { :access_token => @user.facebook_access_token, :link => image_post_url, :picture => @image_post.image.url(:default, false) }
            if @image_post.text
              query[:message] = @image_post.text
            end 
            self.class.post("/me/feed", :query => query)
          rescue
            logger.error("#{@user.username} Facebook share image post failed")
          end
        else
          logger.error("#{@user.username} Facebook token expired, can not share image post")
        end
      else
        logger.error("#{@user.username} not connected to Facebook, can not share image post")
      end
    end
    #MVR - tweet
    if (params['tweet'] == "1")
      if !@user.twitter_access_token.blank? && !@user.twitter_token_secret.blank?
        oauth_client = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
        oauth_client.authorize_from_access(@user.twitter_access_token, @user.twitter_token_secret)
        client = Twitter::Base.new(oauth_client)
        if @image_post.text.blank?
          tweet = "Check out my photo from \"#{@blogcast.title}\" via @Blogcastr #{@image_post.short_url}"
        else
          if @image_post.text.length > 119 
            tweet = "#{@image_post.text[0..116]}... #{@image_post.short_url}"
          else
            tweet = "#{@image_post.text} #{@image_post.short_url}"
          end
        end
        begin
          client.update(tweet)
        rescue
          logger.error("Failed to make image post tweet for #{@user.username}")
        end
      else
        logger.error("#{@user.username} not connected to Twitter, can not make image post tweet")
      end
    end
    respond_to do |format|
      format.js
      format.html { flash[:success] = "Image post posted successfully"; redirect_to :back}
      format.xml { render :xml => @image_post }
      format.json { render :json => @image_post }
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
        format.js { @error = "Unable to find image post"; render :action => "error" }
        format.html { flash[:error] = "Unable to find image post"; redirect_to :back }
        #TODO: fix xml and json support
        format.xml { render :xml => @image_post.errors, :status => :unprocessable_entity }
        format.json { render :json => @image_post.errors, :status => :unprocessable_entity }
      end
      return
    end
    @image_post.destroy
    respond_to do |format|
      format.js
      format.html { flash[:notice] = "Image post deleted successfully"; redirect_to :back }
      format.xml { render :xml => @image_post }
      format.json { render :json => @image_post }
    end
  end
end
