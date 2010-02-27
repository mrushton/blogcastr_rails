class SettingsController < ApplicationController
  before_filter :authenticate

  def edit
    @user = current_user
    #MVR - find setting object or create it 
    @setting = Setting.find_or_create_by_user_id(@user.id)
    @username_possesive = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
    @themes = Theme.all
  end

  def update
    @user = current_user
    #MVR - setting object exists
    Setting.update(@user.setting.id, params[:setting])
    #TODO: this isn't used by the web interface so add xml/json support
    render :template => 'settings/edit'
  end

  def account
    @user = current_user
    #MVR - setting object is guaranteed to exist
    @setting = @user.setting
    #MVR - make a copy of the setting object
    @account_setting = Marshal.load(Marshal.dump(@setting))
    #MVR - avatar is the only optional argument
    if params[:setting][:avatar].nil?
      #MVR - the paperclip attachment gets set on assignment
      err = @account_setting.update_attributes(:full_name => params[:setting][:full_name], :motto => params[:setting][:motto], :location => params[:setting][:location], :bio => params[:setting][:bio], :web => params[:setting][:web], :time_zone => params[:setting][:time_zone])
    else
      err = @account_setting.update_attributes(:full_name => params[:setting][:full_name], :motto => params[:setting][:motto], :location => params[:setting][:location], :bio => params[:setting][:bio], :web => params[:setting][:web], :time_zone => params[:setting][:time_zone], :avatar => params[:setting][:avatar])
    end
    if err 
      flash[:settings_tab] = "account"
      flash[:success] = "Changes saved!"
      redirect_to settings_path 
    else
      @settings_tab = "account"
      @username_possesive = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
      @themes = Theme.all
      render :action => "edit"
    end
  end
  
  def appearance
    @user = current_user
    #MVR - setting object is guaranteed to exist
    @setting = @user.setting
    #MVR - make a copy of the setting object
    @appearance_setting = Marshal.load(Marshal.dump(@setting))
    #MVR - are we using a theme or custom background?
    if params[:setting][:use_background_image] == "1"
      #MVR - background is the only optional argument
      if params[:setting][:background_image].nil?
        #MVR - the paperclip attachment gets set on assignment
        err = @appearance_setting.update_attributes(:use_background_image => params[:setting][:use_background_image], :tile_background_image => params[:setting][:tile_background_image], :scroll_background_image => params[:setting][:scroll_background_image], :background_color => params[:setting][:background_color])
      else
        err = @appearance_setting.update_attributes(:use_background_image => params[:setting][:use_background_image], :tile_background_image => params[:setting][:tile_background_image], :scroll_background_image => params[:setting][:scroll_background_image], :background_color => params[:setting][:background_color], :background_image => params[:setting][:background_image])
      end
    else
        err = @appearance_setting.update_attributes(:use_background_image => params[:setting][:use_background_image], :theme_id => params[:setting][:theme_id])
    end
    if err 
      flash[:settings_tab] = "appearance"
      if params[:setting][:use_background_image] == "1"
        flash[:appearance_view] = "custom-background"
      else
        flash[:appearance_view] = "themes"
      end
      flash[:success] = "Changes saved!"
      redirect_to settings_path 
    else
      @settings_tab = "appearance"
      if params[:setting][:use_background_image] == "1" 
        @appearance_view = "custom-background" 
      else
        @appearance_view = "themes"
      end
      @themes = Theme.all
      @username_possesive = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
      render :action => "edit"
    end
  end

  #MVR - update a user's password
  def password 
    @user = current_user
    #MVR - check current password
    if @user.authenticated?(params[:current_password])
      #MVR - make a copy of the setting object
      @password_user = Marshal.load(Marshal.dump(@user))
      #MVR - verify other fields
      err = @password_user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
      if err 
        flash[:settings_tab] = "password"
        flash[:success] = "Password updated!"
        redirect_to settings_path 
      else
        @setting = @user.setting
        @settings_tab = "password"
        @themes = Theme.all
        @username_possesive = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
        render :action => "edit"
      end
    else
      #AS DESIGNED: just use flash for current password error it is more consistent
      flash[:settings_tab] = "password"
      flash[:error] = "Current password is incorrect"
      redirect_to settings_path 
      #MVR - below is support for using objects and not flash
      #@password_user.errors.add_to_base("Current password is incorrect")
      #MVR - verify other fields
      #@password_user.password = params[:user][:password]
      #@password_user.password_confirmation = params[:user][:password_confirmation]
      #@password_user.valid?
      #@setting = @user.setting
      #@settings_tab = "password"
      #@themes = Themes.all
      #@username_possesive = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
      #render :action => "edit"
    end
  end
end
