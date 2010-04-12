class SiteController < ApplicationController
  def index
    @user = current_user
    @featured_users = User.find(:all, :conditions => "is_featured = 't'")
  end

  def about
    @user = current_user
    render :layout => "about"
  end
end
