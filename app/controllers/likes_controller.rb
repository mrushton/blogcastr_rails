class LikesController < ApplicationController
  def create
    @blogcast = Blogcast.find(params[:blogcast_id])
    if @blogcast.nil?
      @error = "Unable to like blogcast. Blogcast does not exist."
      render :action => "error"
      return
    end
    user = current_user
    #MVR - make sure user is signed in
    if user.nil?
      @error = "Unable to like \"#{@blogcast.title}\". You are not signed in."
      render :action => "error"
      return
    end
    if user == @blogcast.user
      @error = "Unable to like \"#{@blogcast.title}\". You can not like your own blogcast."
      render :action => "error"
      return
    end
    #MVR - do not allow the same subscription multiple times
    @like = Like.find(:first, :conditions => {:user_id => user.id, :blogcast_id => @blogcast.id})
    if !@like.nil? 
      @error = "Unable to like \"#{@blogcast.title}\". You already like it."
      render :action => "error"
      return
    end
    #MVR - add to database
    @like = Like.new
    @like.user_id = user.id
    @like.blogcast_id = @blogcast.id
    @like.save
  end

  def destroy
    @blogcast = Blogcast.find(params[:blogcast_id])
    if @blogcast.nil?
      @error = "Unable to unlike blogcast. Blogcast does not exist."
      render :action => "error"
      return
    end
    #MVR - make sure user is signed in
    user = current_user 
    if user.nil?
      @error = "Unable to unlike blogcast #{@blogcast.title}. You are not signed in."
      render :action => "error"
      return
    end
    begin
      @like = user.likes.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @error = "Unable to unlike blogcast #{@blogcast.title}. Invalid like id."
      render :action => "error"
      return
    end
    @like.destroy
  end
end
