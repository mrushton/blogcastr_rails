class SiteController < ApplicationController
  def index
    @user = current_user
    @featured_users = User.find(:all, :conditions => "is_featured = 't'", :order => "random()", :limit => 8)
    @featured_blogcasts = Blogcast.find(:all, :conditions => "is_featured = 't'", :order => "random()", :limit => 2)
    @recent_blogcasts = Blogcast.find(:all, :conditions => [ "starting_at < ? AND starting_at > ?", Time.zone.now, 1.month.ago ], :order => "random()", :limit => 2)
    render :layout => "root"
  end

  def about
    @user = current_user
    render :layout => "about"
  end
end
