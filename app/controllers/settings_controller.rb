class SettingsController < ApplicationController
  before_filter :authenticate

  def edit
    @user = current_user
    #MVR - find setting object or create it 
    @setting = Setting.find_or_create_by_user_id(@user.id)
  end

  def update
    @user = current_user
    #MVR - find setting object or create it 
    @setting = Setting.find_or_create_by_user_id(@user.id)
    Setting.update(@setting.id, params[:setting])
    redirect_to :back
  end
end
