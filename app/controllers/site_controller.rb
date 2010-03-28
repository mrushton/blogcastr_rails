class SiteController < ApplicationController
  def index
    @user = current_user
    @featured_users = User.find_by_sql("SELECT * FROM users WHERE username == 'mrushton' OR username == 'krushtown' OR username == 'techstars'")
  end

  def about
    @user = current_user
    render :layout => "about"
  end
end
