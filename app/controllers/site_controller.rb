class SiteController < ApplicationController
  def index
    @user = current_user
    #MVR - redirect to home if logged in
    if !@user.nil? && @user.instance_of?(BlogcastrUser)
      redirect_to home_path
      return
    end
    #MVR - only select users that have avatars
    @discover_users = BlogcastrUser.find(:all, :joins => "inner join settings on users.id = settings.user_id", :conditions => "settings.avatar_file_name IS NOT NULL", :order => "random()", :limit => "18")
    @featured_blogcasts = Blogcast.find(:all, :conditions => "is_featured = 't'", :order => "random()", :limit => 2)
    @recent_blogcasts = Blogcast.find(:all, :conditions => [ "starting_at < ? AND starting_at > ?", Time.zone.now, 1.month.ago ], :order => "random()", :limit => 2)
    @featured_users = User.find(:all, :conditions => "is_featured = 't'", :order => "random()", :limit => 8)
    render :layout => "root"
  end

  def about
    @user = current_user
    @kyle = BlogcastrUser.find_by_username("krushtown")
    @kyle_setting = @kyle.setting
    @matt = BlogcastrUser.find_by_username("mrushton")
    @matt_setting = @matt.setting
    render :layout => "about"
  end

  def privacy
    @user = current_user
    @title = "Blogcastr - Privacy Policy"
    render :layout => "privacy-and-terms"
  end

  def terms
    @user = current_user
    @title = "Blogcastr - Terms of Service"
    render :layout => "privacy-and-terms"
  end
end
