class TextPostsController < ApplicationController
  include HTTParty

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
  base_uri "https://graph.facebook.com"

  def create
    if params[:authentication_token].nil?
      @user = current_user
    else 
      @user = rest_current_user
    end
    @text_post = TextPost.new(params[:text_post])
    #MVR - find blogcast
    begin
      @blogcast = @user.blogcasts.find(params[:blogcast_id]) 
    rescue RecordNotFound
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
    #MVR - create short url
    text_post_url = "http://" + HOST + "/" + @user.username + "/" + @blogcast.year.to_s + "/" + @blogcast.month.to_s + "/" + @blogcast.day.to_s + "/" + @blogcast.link_title + "/posts/" + @text_post.id.to_s
    #TODO: probably should put this in after_create but need to work out the behavior of updating 
    bitly = Bitly.new(BITLY_LOGIN, BITLY_API_KEY)
    begin
      @text_post.short_url = bitly.shorten(text_post_url)
    rescue BitlyError => e
      logger.error(e.message)
    else
      logger.error("Shorten text post url failed")
    end
    @text_post.save
    begin
      thrift_user = Thrift::User.new
      thrift_user.id = @user.id
      thrift_user.type = "BlogcastrUser"
      thrift_user.username = @user.username
      thrift_user.url = profile_path :username => @user.username
      thrift_user.avatar_url = @user.setting.avatar.url(:original)
      thrift_text_post = Thrift::TextPost.new
      thrift_text_post.id = @text_post.id
      thrift_text_post.created_at = @text_post.created_at.xmlschema
      thrift_text_post.from = @text_post.from
      thrift_text_post.text = @text_post.text
      thrift_text_post.url = blogcast_post_permalink_url(:username => @user.username, :year => @blogcast.year, :month => @blogcast.month, :day => @blogcast.day, :title => @blogcast.link_title, :post_id => @text_post.id) 
      thrift_text_post.short_url = @text_post.short_url
      #MVR - send text post to muc room
      err = thrift_client.send_text_post_to_muc_room(@user.username, HOST, "Blogcast." + @blogcast.id.to_s, thrift_user, thrift_text_post)
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
    #MVR - Facebook share
    if (params['facebook_share'] == "1")
      if @user.facebook_access_token && @user.facebook_expires_at
        if @user.facebook_expires_at > Time.now
          begin
            #MVR - post to news feed
            query = { :access_token => @user.facebook_access_token, :message => "#{@text_post.text} #{@text_post.short_url}" }
            self.class.post("/me/feed", :query => query)
          rescue
            logger.error("#{@user.username} Facebook share blogcast failed")
          end
        else
          logger.error("#{@user.username} Facebook token expired, can not share blogcast")
        end
      else
        logger.error("#{@user.username} not connected to Facebook, can not share blogcast")
      end
    end
    #MVR - tweet
    if (params['tweet'] == "1")
      if !@user.twitter_access_token.blank? && !@user.twitter_token_secret.blank?
        oauth_client = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
        oauth_client.authorize_from_access(@user.twitter_access_token, @user.twitter_token_secret)
        client = Twitter::Base.new(oauth_client)
        if @text_post.text.length > 119 
          tweet = "#{@text_post.text[0..116]}... #{@text_post.short_url}"
        else
          tweet = "#{@text_post.text} #{@text_post.short_url}"
        end
        begin
          client.update(tweet)
        rescue
          logger.error("Failed to make text post tweet for #{@user.username}")
        end
      else
        logger.error("#{@user.username} not connected to Twitter, can not make text post tweet")
      end
    end
    respond_to do |format|
      format.js
      format.html { flash[:notice] = "Text post posted successfully"; redirect_to :back}
      format.xml { render :xml => @text_post }
      format.json { render :json => @text_post }
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
