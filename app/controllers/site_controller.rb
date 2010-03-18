class SiteController < ApplicationController
  def index
    @user = current_user
  end

  def about
    @user = current_user
    render :layout => "about"
  end
end
