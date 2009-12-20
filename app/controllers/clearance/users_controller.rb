class Clearance::UsersController < ApplicationController
  #MVR - redirect to dashboard
  before_filter :redirect_to_dashboard, :only => [:new, :create], :if => :signed_in_as_blogcastr_user?
  filter_parameter_logging :password

  def new
    @blogcastr_user = BlogcastrUser.new(params[:blogcastr_user])
    render :template => 'users/new', :layout => true
  end

  def create
    @blogcastr_user = BlogcastrUser.new(params[:blogcastr_user])
    if @blogcastr_user.save
      #MVR - create setting
      utc_offset = params[:utc_offset]
      if !utc_offset.nil?
        #AS DESIGNED - only try to find US time zones
        time_zone = nil
        ActiveSupport::TimeZone.us_zones.each do |zone|
          #MVR - calling zone.utc_offset ignores daylight savings time
          if zone.tzinfo.current_period.utc_total_offset == utc_offset.to_i*60
            time_zone = zone
            break
          end
        end
        if !time_zone.nil?
          @setting = Setting.create(:user_id => @blogcastr_user.id, :time_zone => time_zone.name)
        else
          #MVR - set time zone to UTC if we can't find it
          @setting = Setting.create(:user_id => @blogcastr_user.id, :time_zone => "UTC")
        end
      end
      begin
        #AS DESIGNED: create ejabberd account here since password gets encrypted
        thrift_client.create_user(@blogcastr_user.name, HOST, params[:blogcastr_user][:password])
        thrift_client_close
      rescue
        #TODO: could use flash in this case could be more appropriate
        @blogcastr_user.errors.add_to_base "Unable to create ejabberd account"
        @blogcastr_user.destroy
        @setting.destroy
        render :template => 'users/new'
        return
      end
      ClearanceMailer.deliver_confirmation @blogcastr_user
      flash_notice_after_create
      redirect_to url_after_create
    else
      render :template => 'users/new'
    end
  end

  private

  def flash_notice_after_create
    flash[:notice] = translate(:deliver_confirmation, :scope => [:clearance, :controllers, :users], :default => "You will receive an email shortly. " << "It contains instructions for confirming your account.")
  end

  def url_after_create
    new_session_url
  end

  def redirect_to_dashboard
    redirect_to dashboard_url
  end
end
