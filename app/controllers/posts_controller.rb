class PostsController < ApplicationController
  #MVR - needed to work around CSRF for REST api
  #TODO: add CSRF before filter for standard authentication only, other option is to modify Rails to bypass CSRF for certain user agents
  skip_before_filter :verify_authenticity_token
  before_filter :set_time_zone
  before_filter do |controller|
    #AS DESIGNED: check format because params array is not yet created
    if controller.request.format.html? || controller.request.format.js?
      controller.authenticate
    else 
      controller.rest_authenticate
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
        format.js {@error = "Unable to delete post. Post does not exist."; render :action => "error"}
        format.html {flash[:error] = "Unable to find post"; redirect_to :back}
        format.xml {head :not_found}
        format.json {head :not_found}
      end
      return
    end
    if !@post.destroy
      respond_to do |format|
        format.js {@error = "Unable to delete post."; render :action => "error"}
        format.html {flash[:error] = "Unable to delete post"; redirect_to :back}
        format.xml {render :xml => @post.errors, :status => :unprocessable_entity}
        format.json {render :json => @post.errors, :status => :unprocessable_entity}
      end
      return
    end
    #TODO: send to ejabberd
    respond_to do |format|
      format.js
      format.html {flash[:success] = "Post deleted successfully"; redirect_to :back}
      format.xml {head :ok}
      format.json {head :ok}
    end
  end
end
