# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'thrift'
require 'blogcastr'
require 'tzinfo'

class ApplicationController < ActionController::Base
  include Clearance::Authentication
  #MVR - includes thrift definition
  #include Blogcastr 
  #MVR - Twitter NoAuth include for api requests requiring no authentication
  include Twitter::NoAuth
  #MVR - Blogcastr includes
  include Authentication

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  filter_parameter_logging :fb_sig_friends

  #TODO: fix me!
  def thrift_client
    return @thrift_client if defined?(@thrift_client)
    @thrift_socket = Thrift::Socket.new(THRIFT_HOST, THRIFT_PORT)
    #TODO: investigate multiple transports 
    @thrift_transport = Thrift::BufferedTransport.new(@thrift_socket)
    @thrift_transport.open
    @thrift_protocol = Thrift::BinaryProtocol.new(@thrift_transport)
    @thrift_client = Thrift::Blogcastr::Client.new(@thrift_protocol)
  end

  def thrift_client_close
    @thrift_transport.close if defined?(@thrift_transport)
  end

  def set_time_zone
    if params[:authentication_token].nil?
      @current_user = current_user
    else 
      @current_user = rest_current_user
    end
    if !@current_user.nil?
      if !@current_user.setting.nil?
        @time_zone = @current_user.setting.time_zone
        if !@time_zone.nil?
          Time.zone = @time_zone
        end
      end
    end
  end

  def set_blogcast_time_zone
    #MVR - if time zone has not been set, set it to the blogcast time zone
    if @time_zone.nil?
      if !params[:username].nil?
        blogcast_user = BlogcastrUser.find_by_username(params[:username])
        if !blogcast_user.nil?
          @time_zone = blogcast_user.setting.time_zone
          if !@time_zone.nil?
            Time.zone = @time_zone
          end
        end
      end
    end
  end

  def set_cache_headers
    #MVR - turn off browser caching for ajax
    headers["Pragma"] = "no-cache";
    headers["Cache-Control"] = "must-revalidate";
    headers["Cache-Control"] = "no-cache";
    headers["Cache-Control"] = "no-store";
    headers["Expires"] = "0";
  end
end
