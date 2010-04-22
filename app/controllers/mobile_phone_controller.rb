class MobilePhoneController < ApplicationController
  before_filter :authenticate

  def create
    @user = current_user
    #MVR - setting object is guaranteed to exist
    @setting = @user.setting
    #MVR - make a copy of the setting object
    @mobile_phone_setting = Marshal.load(Marshal.dump(@setting))
    confirmation_token = Digest::SHA1.hexdigest("--#{Time.now}--")
    err = @mobile_phone_setting.update_attributes(:mobile_phone_carrier_id => params[:setting][:mobile_phone_carrier_id], :mobile_phone_number => params[:setting][:mobile_phone_number], :mobile_phone_confirmed => false, :mobile_phone_confirmation_sent => true, :mobile_phone_confirmation_token => confirmation_token[0,5])
    if err
      #MVR - reload setting since we are using two different objects
      @setting.reload
      MobilePhoneMailer.deliver_confirm @user
      flash[:settings_tab] = "notifications"
      flash[:notifications_view] = "mobile-phone"
      flash[:info] = "A confirmation text has been sent to your mobile phone."
      redirect_to settings_path 
    else
      @settings_tab = "notifications"
      @notifications_view = "mobile-phone"
      @username_possesive = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
      @themes = Theme.all
      @mobile_phone_carriers = MobilePhoneCarrier.find(:all).map {|m| [m.name, m.id]}
      #AS DESIGNED: this is not part of the settings controller
      render :template => "settings/edit", :layout => "settings"
    end
  end

  def confirm
    @user = current_user
    #MVR - setting object is guaranteed to exist
    @setting = @user.setting
    #AS DESIGNED: using a non-model form
    if (params[:mobile_phone_confirmation_token] == @setting.mobile_phone_confirmation_token)
      err = @setting.update_attributes(:mobile_phone_confirmed => true)
    else
      flash[:settings_tab] = "notifications"
      flash[:notifications_view] = "mobile-phone"
      flash[:error] = "Invalid confirmation code."
      redirect_to settings_path 
      return
    end
    if err
      flash[:settings_tab] = "notifications"
      flash[:notifications_view] = "mobile-phone"
      flash[:success] = "Mobile phone confirmed!"
      redirect_to settings_path 
    else
      flash[:settings_tab] = "notifications"
      flash[:notifications_view] = "mobile-phone"
      flash[:error] = "Oops! Unable to confirm mobile phone."
      redirect_to settings_path 
    end
  end

  def destroy
    @user = current_user
    #MVR - setting object is guaranteed to exist
    @setting = @user.setting
    #MVR - make a copy of the setting object
    @mobile_phone_setting = Marshal.load(Marshal.dump(@setting))
    err = @mobile_phone_setting.update_attributes(:mobile_phone_carrier_id => nil, :mobile_phone_number =>  nil, :mobile_phone_confirmed => false, :mobile_phone_confirmation_sent => false, :mobile_phone_confirmation_token => nil)
    if err
      respond_to do |format|
        format.html {flash[:settings_tab] = "notifications"; flash[:notifications_view] = "mobile-phone"; flash[:success] = "Your mobile phone has been removed."; redirect_to settings_path}
        format.js {@mobile_phone_carriers = MobilePhoneCarrier.find(:all).map {|m| [m.name, m.id]}}
      end
      #flash[:settings_tab] = "notifications"
      #flash[:notifications_view] = "mobile-phone"
      #flash[:success] = "Your mobile phone has been removed."
      #redirect_to settings_path 
    else
      @settings_tab = "notifications"
      @notifications_view = "mobile-phone"
      @username_possesive = @user.username + (@user.username =~ /.*s$/ ? "'":"'s")
      @themes = Theme.all
      @mobile_phone_carriers = MobilePhoneCarrier.find(:all).map {|m| [m.name, m.id]}
      #AS DESIGNED: this is not part of the settings controller
      render :template => "settings/edit", :layout => "settings"
    end
  end
end
