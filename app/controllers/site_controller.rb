class SiteController < ApplicationController
  def index
    @user = current_user
    @featured_users = User.find(:all, :conditions => "is_featured = 't'", :order => "random()", :limit => 8)
    @featured_blogcasts = Blogcast.find(:all, :conditions => "is_featured = 't'", :order => "random()", :limit => 3)
  end

  def about
    @user = current_user
    render :layout => "about"
  end
end
