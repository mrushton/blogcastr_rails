class BlogcastsController < ApplicationController
  before_filter :only => [ "new", "create", "edit", "update", "destroy" ] do |controller|
    if controller.params[:authentication_token].nil?
      controller.authenticate
    else 
      controller.rest_authenticate
    end
  end
  before_filter :set_time_zone
  before_filter :set_facebook_session
  helper_method :facebook_session

  def index
    #MVR - find user by id 
    @user = BlogcastrUser.find_by_username(params[:user_id])
    @setting = @user.setting
    if @user.nil?
      respond_to do |format|
        format.xml { render :xml => "<errors><error>Couldn't find BlogcastrUser with ID=\"#{params[:user_id]}\"</error></errors>", :status => :unprocessable_entity }
        format.json { render :json => "[[\"Couldn't find BlogcastrUser with ID=\"#{params[:user_id]}\"\"]]", :status => :unprocessable_entity }
      end
      return
    end
    respond_to do |format|
      #TODO: limit result set and order by most recent
      format.xml { render :xml => @user.blogcasts.find(:all, :limit => 10, :order => "id DESC").to_xml(:only => [ :id, :title, :description, :starting_at, :updated_at, :name ], :include => :tags) }
      format.json { render :json => @user.blogcasts.find(:all, :limit => 10).to_json(:only => [ :id, :title, :description, :starting_at, :updated_at, :name ], :include => :tags) }
      format.rss {
        @blogcasts = @user.blogcasts.find(:all, :limit => 10, :order => "created_at DESC")
        #MVR - possesive names 
        @possesive_username = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
        @possesive_full_name = @setting.full_name + (@setting.full_name =~ /.*s$/ ? "'":"'s")
        render :layout => false
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
    respond_to do |format|
      format.html {redirect_to blogcast_dashboard_path(:blogcast_id => @blogcast.id)}
      format.xml {render :xml => @blogcast, :status => :created, :location => @blogcast}
      format.json {render :json => @blogcast, :status => :created, :location => @blogcast}
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
    user = current_user
    blogcast = user.blogcasts.find(params[:id])
    if blogcast.nil?
	#TODO: set the flash
	redirect_to :back
    end
    #AS DESIGNED: do an extra query but it's not performance critical
    #TODO: check for link title
    blogcast.update_attributes(params[:blogcast])
    if params[:blogcast][:link_title].nil?
      blogcast.link_title = blogcast.title.downcase.gsub(/[^a-z0-9]/, "-") 
    end
    blogcast.year = blogcast.starting_at.year
    blogcast.month = blogcast.starting_at.month
    blogcast.day = blogcast.starting_at.day
    blogcast.save
    #TODO: handle errors
    redirect_to home_path
  end

  def destroy
    #MVR - authentication
    if params[:authentication_token].nil?
      @user = current_user
    else 
      @user = rest_current_user
    end
    @blogcast = @user.blogcasts.find(params[:id])
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
