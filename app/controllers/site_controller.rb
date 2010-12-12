class SiteController < ApplicationController
  def index
    @user = current_user
    #MVR - only select users that have avatars
    @discover_users = BlogcastrUser.find(:all, :joins => "inner join settings on users.id = settings.user_id", :conditions => "settings.avatar_file_name IS NOT NULL", :order => "random()", :limit => "18")
    @featured_blogcasts = Blogcast.find(:all, :conditions => "is_featured = 't'", :order => "random()", :limit => 2)
    @recent_blogcasts = Blogcast.find(:all, :conditions => [ "starting_at < ? AND starting_at > ?", Time.zone.now, 1.month.ago ], :order => "random()", :limit => 2)
    @featured_users = User.find(:all, :conditions => "is_featured = 't'", :order => "random()", :limit => 8)
    render :layout => "root"
  end

  def about
    @user = current_user
    render :layout => "about"
  end
end
