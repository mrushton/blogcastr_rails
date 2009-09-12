class DashboardController < ApplicationController
  before_filter :authenticate

  def index
    @user = current_user
  end
end
