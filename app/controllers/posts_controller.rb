class PostsController < ApplicationController
  #MVR - needed to work around CSRF for REST api
  #TODO: add CSRF before filter for standard authentication only, other option is to modify Rails to bypass CSRF for certain user agents
  skip_before_filter :verify_authenticity_token
  before_filter :set_time_zone
  before_filter :only => [ "destroy" ] do |controller|
    #AS DESIGNED: check format because params array is not yet created
    if controller.request.format.html? || controller.request.format.js?
      controller.authenticate
    else 
      controller.rest_authenticate
    end
  end

  def index
    #MVR - find blogcast by id 
    begin 
      @blogcast = Blogcast.find(params[:blogcast_id])
    rescue
      respond_to do |format|
        format.xml { render :xml => "<errors><error>Couldn't find Blogcast with ID=\"#{params[:blogcast_id]}\"</error></errors>", :status => :unprocessable_entity }
        format.json { render :json => "[[\"Couldn't find BlogcastrUser with ID=\"#{params[:blogcast_id]}\"\"]]", :status => :unprocessable_entity }
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
      @posts = @blogcast.posts.find(:all, :limit => count, :order => "id DESC")
    else
      @posts = @blogcast.posts.find(:all, :conditions => [ "id <= ?", max_id ], :limit => count, :order => "id DESC")
    end
    respond_to do |format|
      #TODO: limit result set and order by most recent
      format.xml { }
      format.json {
        if (max_id.nil?)  
          render :json => @user.blogcasts.find(:all, :limit => count, :order => "id DESC").to_json(:only => [ :id, :title, :description, :starting_at, :updated_at, :name ], :include => :tags)
        else
          render :json => @user.blogcasts.find(:all, :conditions => [ "id <= ?", max_id], :limit => count, :order => "id DESC").to_json(:only => [ :id, :title, :description, :starting_at, :updated_at, :name ], :include => :tags)
        end
      }
    end
  end

  #AS DESIGNED: process all post types the same 
  def destroy
    if params[:authentication_token].nil?
      @user = current_user
    else 
      @user = rest_current_user
    end
    #MVR - find post
    @post = @user.posts.find(params[:id]) 
    if @post.nil?
      respond_to do |format|
        format.js { @error = "Oops! Post does not exist."; render :action => "error" }
        format.html { flash[:error] = "Oops! Post does not exist."; redirect_to :back }
        format.xml { head :not_found }
        format.json { head :not_found }
      end
      return
    end
    if !@post.destroy
      respond_to do |format|
        format.js { @error = "Oops! Unable to delete post."; render :action => "error" }
        format.html { flash[:error] = "Oops! Unable to delete post."; redirect_to :back }
        format.xml { render :xml => @post.errors, :status => :unprocessable_entity }
        format.json { render :json => @post.errors, :status => :unprocessable_entity }
      end
      return
    end
    #AS DESIGNED: do not update blogcast page dynamically
    respond_to do |format|
      format.js
      format.html { flash[:success] = "Post deleted successfully"; redirect_to :back }
      format.xml { head :ok }
      format.json { head :ok }
    end
  end
end
