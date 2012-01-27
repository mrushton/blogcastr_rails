class BlogcastsController < ApplicationController
  #MVR - needed to work around CSRF for REST api
  #TODO: add CSRF before filter for standard authentication only, other option is to modify Rails to bypass CSRF for certain user agents
  skip_before_filter :verify_authenticity_token
  before_filter :set_time_zone
  before_filter :only => [ "new", "create", "edit", "update", "destroy" ] do |controller|
    if controller.params[:authentication_token].nil?
      controller.authenticate
    else 
      controller.rest_authenticate
    end
  end

  def index
    #MVR - find user by id 
    @user = BlogcastrUser.find(params[:user_id])
    if @user.nil?
      respond_to do |format|
        format.xml { render :xml => "<errors><error>Couldn't find BlogcastrUser with ID=\"#{params[:user_id]}\"</error></errors>", :status => :unprocessable_entity }
        format.json { render :json => "[[\"Couldn't find BlogcastrUser with ID=\"#{params[:user_id]}\"\"]]", :status => :unprocessable_entity }
      end
      return
    end
    if params[:count].nil?
      count = 10
    else
      count = params[:count].to_i
      if count > 100
        count = 100
      end
    end
    if !params[:max_id].nil?
      max_id = params[:max_id].to_i
    end
    if (max_id.nil?)  
      @blogcasts = @user.blogcasts.find(:all, :limit => count, :order => "id DESC")
    else
      @blogcasts = @user.blogcasts.find(:all, :conditions => [ "id <= ?", max_id ], :limit => count, :order => "id DESC")
    end
    #TODO: work around for making thrift calls from view
    @thrift_client = thrift_client
    respond_to do |format|
      format.xml { }
      format.json {
          #TODO: fix json support 
          render :json => @blogcasts.to_json(:only => [ :id, :title, :description, :starting_at, :updated_at, :name ], :include => :tags)
      }
      format.rss {
        @setting = @user.setting
        #MVR - possesive names 
        @possesive_username = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
        @possesive_full_name = @setting.full_name + (@setting.full_name =~ /.*s$/ ? "'":"'s")
        render :layout => false
      }
    end
  end

  def show
    #MVR - find blogcast by id 
    begin
      @blogcast = Blogcast.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.xml { render :xml => "<errors><error>Couldn't find Blogcast with ID=\"#{params[:id]}\"</error></errors>", :status => :unprocessable_entity }
        format.json { render :json => "[[\"Couldn't find Blogcast with ID=\"#{params[:id]}\"\"]]", :status => :unprocessable_entity }
      end
      return
    end
    @user = @blogcast.user
    @image_post = @blogcast.posts.find(:first, :conditions => "type = 'ImagePost'", :order => "id DESC")
    #TODO: work around for making thrift calls from view
    @thrift_client = thrift_client
    respond_to do |format|
      format.xml { }
      format.json {
          #TODO: fix json support 
          render :json => @blogcast.to_json(:only => [ :id, :title, :description, :starting_at, :updated_at, :name ], :include => :tags)
      }
    end
  end

  def new
    @user = current_user
    @blogcast = Blogcast.new
    #MVR - set start time to now by default
    @blogcast.starting_at = Time.now
    render :layout => "new_blogcast"
  end

  def create
    #MVR - authentication
    if params[:authentication_token].nil?
      @user = current_user
    else 
      @user = rest_current_user
    end
    #MVR - needed for browser refreshing
    if request.format.html? && params[:blogcast].nil?
      redirect_to new_blogcast_path
      return
    end
    #AS DESIGNED: rest api passes parameters in the same way as web 
    @blogcast = Blogcast.new(params[:blogcast])
    @blogcast.user_id = @user.id
    #MVR - if starting_at is not set, set it to current time
    if @blogcast.starting_at.nil?
      @blogcast.starting_at = Time.now
    end
    #MVR - if link_title is not set, set it to lowercase title with non-alphanumeric characters replaced with an underscore
    if @blogcast.link_title.blank?
      @blogcast.link_title = @blogcast.title.downcase.gsub(/[^a-z0-9]/, "-") 
    end
    @blogcast.year = @blogcast.starting_at.year
    @blogcast.month = @blogcast.starting_at.month
    @blogcast.day = @blogcast.starting_at.day
    #MVR - tags must be in database for acts_as_solr
    if !params[:tags].blank?
      tags = params[:tags].split(/,/).map { |tag| tag.gsub(/^\s*/, "") }
      for tag in tags
        #MVR - add tag if not present
        #AS DESIGNED: no error checking just proceed
        user_tag = @user.tags.find_or_create_by_name(tag)
        blogcast_tag = BlogcastTag.new
        blogcast_tag.tag_id = user_tag.id 
        @blogcast.blogcast_tags.push(blogcast_tag)
      end
    end
    begin
      #MVR - create bitly link
      json = Net::HTTP.get(URI.parse("http://api.bit.ly/v3/shorten?login=" + BITLY_LOGIN + "&apiKey=" + BITLY_API_KEY + "&uri=" + "http://" + HOST + "/" + @user.username + "/" + @blogcast.year.to_s + "/" + @blogcast.month.to_s + "/" + @blogcast.day.to_s + "/" + @blogcast.link_title))
      response = ActiveSupport::JSON::decode(json)
      if response["status_code"] == 200
        @blogcast.short_url = response["data"]["url"]
      end
    rescue
    end
    if !@blogcast.save
      respond_to do |format|
        format.html {@title = "New Blogcast"; render :template => "blogcasts/new", :layout => "default"}
        format.xml {render :xml => @blogcast.errors, :status => :unprocessable_entity}
        #TODO: fix json support
        format.json {render :json => @blogcast.errors, :status => :unprocessable_entity}
      end
      return
    end
    begin  
      #MVR - create muc room
      thrift_client.create_muc_room(@user.username, HOST, "Blogcast."+@blogcast.id.to_s, @blogcast.title, "")
      thrift_client_close
    rescue
      @blogcast.errors.add_to_base "Unable to create blogcast muc room"
      @blogcast.destroy
      respond_to do |format|
        format.html {@title = "New Blogcast"; render :template => "blogcasts/new", :layout => "default"}
        format.xml {render :xml => @blogcast.errors, :status => :unprocessable_entity}
        format.json {render :json => @blogcast.errors, :status => :unprocessable_entity}
      end
      return
    end
    #MVR - tweet
    if (params['tweet'] == "1")
      if !@user.twitter_access_token.blank? && !@user.twitter_token_secret.blank?
        oauth_client = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
        oauth_client.authorize_from_access(@user.twitter_access_token, @user.twitter_token_secret)
        client = Twitter::Base.new(oauth_client)
        tweet = "Check out \"#{@blogcast.title}\" via @Blogcastr #{@blogcast.short_url}"
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
      format.html {redirect_to blogcast_dashboard_path(:blogcast_id => @blogcast.id)}
      format.xml {render :xml => @blogcast}
      format.json {render :json => @blogcast}
    end
  end

  def edit
    @user = current_user
    @blogcast = @user.blogcasts.find(params[:id])
    if @blogcast.nil?
      #MVR - treat this as a 404 error
      render :file => "public/404.html", :layout => false, :status => 404
      return
    end
    render :layout => "default"
  end

  def update
    #MVR - authentication
    if params[:authentication_token].nil?
      @user = current_user
    else 
      @user = rest_current_user
    end
    @blogcast = @user.blogcasts.find(params[:id])
    #TODO: error handling
    #MVR - save some info to determine if we need to update the short url
    @link_title = @blogcast.link_title
    @starting_at = @blogcast.starting_at
    #AS DESIGNED: only update the link title if set explicitly 
    @blogcast.attributes = params[:blogcast]
    @blogcast.year = @blogcast.starting_at.year
    @blogcast.month = @blogcast.starting_at.month
    @blogcast.day = @blogcast.starting_at.day
    #MVR - tags must be in database for acts_as_solr
    if !params[:tags].nil?
      #MVR - delete all tags
      @blogcast.blogcast_tags.delete_all
      tags = params[:tags].split(/,/).map { |tag| tag.gsub(/^\s*/, "") }
      for tag in tags
        #MVR - add tag if not present
        #AS DESIGNED: no error checking just proceed
        user_tag = @user.tags.find_or_create_by_name(tag)
        blogcast_tag = BlogcastTag.new
        blogcast_tag.tag_id = user_tag.id 
        @blogcast.blogcast_tags.push(blogcast_tag)
      end
    end
    begin
      #MVR - create bitly link if the permalink has changed
      if (@starting_at != @blogcast.starting_at || @link_title != @blogcast.link_title)
        json = Net::HTTP.get(URI.parse("http://api.bit.ly/v3/shorten?login=" + BITLY_LOGIN + "&apiKey=" + BITLY_API_KEY + "&uri=" + "http://" + HOST + "/" + @user.username + "/" + @blogcast.year.to_s + "/" + @blogcast.month.to_s + "/" + @blogcast.day.to_s + "/" + @blogcast.link_title))
        response = ActiveSupport::JSON::decode(json)
        if response["status_code"] == 200
          @blogcast.short_url = response["data"]["url"]
        end
      end
    rescue
    end
    if !@blogcast.save
      respond_to do |format|
        format.html { }
        format.xml { render :xml => @blogcast.errors, :status => :unprocessable_entity }
      end
      return
    end
    @image_post = @blogcast.posts.find(:first, :conditions => "type = 'ImagePost'", :order => "id DESC")
    #TODO: work around for making thrift calls from view
    @thrift_client = thrift_client
    respond_to do |format|
      format.js
      format.html { redirect_to home_path }
      format.xml { render :action => "show" }
    end
  end

  def destroy
    #MVR - authentication
    if params[:authentication_token].nil?
      @user = current_user
    else 
      @user = rest_current_user
    end
    @blogcast = @user.blogcasts.find(params[:id])
    if @blogcast.nil?
      respond_to do |format|
        format.js {
          @error = "Oops! Blogcast does not exist."
          render :action => "error"
        }
        format.xml { head :not_found }
        format.json { head :not_found }
      end
      return
    end
    if !@blogcast.destroy
      respond_to do |format|
        format.js { @error = "Oops! Unable to delete #{@blogcast.title}."; render :action => "error" }
        format.xml { render :xml => @blogcast.errors, :status => :unprocessable_entity }
        format.json { render :json => @blogcast.errors, :status => :unprocessable_entity }
      end
      return
    end
    respond_to do |format|
      format.js
      format.xml { head :ok }
      format.json { head :ok }
    end
  end
end
