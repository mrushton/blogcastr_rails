class BlogcastsController < ApplicationController
  before_filter :authenticate, :only => ["new", "create", "edit", "update", "destroy"]
  before_filter :set_time_zone
  before_filter :set_facebook_session
  after_filter :view, :only => ["show", "show_permalink"]
  helper_method :facebook_session

  def new
    @user = current_user
    @blogcast = Blogcast.new
    #MVR - set the timezone
    @title = "New Blogcast"
    render :layout => "default"
  end

  def create
    user = current_user
    #TODO: check for link title 
    blogcast = Blogcast.new(params[:blogcast])
    blogcast.user_id = user.id
    #MVR - if starting_at is not set, set it to current time
    if blogcast.starting_at.nil?
      blogcast.starting_at = Time.now
    end
    #MVR - if link_title is not set, set it to lowercase title with non-alphanumeric characters replaced with an underscore
    if blogcast.link_title.nil?
      blogcast.link_title = blogcast.title.downcase.gsub(/[^a-z0-9]/, "_") 
    end
    blogcast.year = blogcast.starting_at.year
    blogcast.month = blogcast.starting_at.month
    blogcast.day = blogcast.starting_at.day
    blogcast.save
    #TODO: handle js and errors
    redirect_to home_path
  end

  def show
    respond_to do |format|
      begin
        @blogcast = Blogcast.find(params[:id])
        format.html {redirect_to blogcast_permalink_path(:username => @blogcast.user.name, :year => @blogcast.year, :month => @blogcast.month, :day => @blogcast.day, :title => @blogcast.link_title)}
        format.xml {render :xml => @blogcast.to_xml}
        format.json {render :json => @blogcast.to_json}
      rescue ActiveRecord::RecordNotFound => error
        format.html {render :file => "public/404.html", :layout => false, :status => 404}
        format.xml {render :xml => "<errors><error>#{error.message}</error></errors>", :status => :unprocessable_entity}
        format.json {render :json => "[[#{error.message}]]", :status => :unprocessable_entity}
      end
    end
  end

  def edit
    @user = current_user;
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
      blogcast.link_title = blogcast.title.downcase.gsub(/[^a-z0-9]/, "_") 
    end
    blogcast.year = blogcast.starting_at.year
    blogcast.month = blogcast.starting_at.month
    blogcast.day = blogcast.starting_at.day
    blogcast.save
    #TODO: handle errors
    redirect_to home_path
  end

  def edit
    @user = current_user;
    @blogcast = @user.blogcasts.find(params[:id])
    if @blogcast.nil?
      #MVR - treat this as a 404 error
      render :file => "public/404.html", :layout => false, :status => 404
      return
    end
    render :layout => "default"
  end

  def destroy
    #TODO: implement destroy
    redirect_to home_path
  end

  def permalink
    @blogcast_user = User.find_by_name(params[:username])
    if @blogcast_user.nil?
      #MVR - treat this as a 404 error
      render :file => "public/404.html", :layout => false, :status => 404
      return
    end
    @blogcast = @blogcast_user.blogcasts.find(:first, :conditions => {:year => params[:year].to_i, :month => params[:month].to_i, :day => params[:day].to_i, :link_title => params[:title]})
    if @blogcast.nil?
      #MVR - treat this as a 404 error
      render :file => "public/404.html", :layout => false, :status => 404
      return
    end
    #MVR - get settings
    @blogcast_setting = @blogcast_user.setting
    @user = current_user
    if !@user.nil?
      if @user.instance_of?(BlogcastrUser)
        #MVR - does user like blog or not
        if @user != @blogcast_user
          @like = @user.likes.find(:first, :conditions => {:blogcast_id => @blogcast.id}) 
        end
      end
      @text_comment = TextComment.new(:from => "Web")
    end
    #MVR - posts 
    @posts = @blogcast.posts.find(:all, :order => "created_at DESC") 
    @num_posts = @blogcast.posts.count
    #MVR - comments
    @num_comments = @blogcast.comments.count
    #TODO: live viewers
    @num_viewers = 0
    #TODO: views
    @num_views = @blogcast.views.count
    #TODO: do not use find_by_sql
    @likes = User.find_by_sql(["SELECT users.* FROM likes, users WHERE likes.blogcast_id = ? AND likes.user_id = users.id LIMIT 30", @blogcast.id])
    @num_likes = @blogcast.likes.count 
  end

  private

  def view
    if !@blogcast.nil?
      if @user.nil?
        @blogcast.views.create
      else
        @blogcast.views.create(:user_id => @user.id)
      end
    end
  end
end