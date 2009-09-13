require 'thrift'
require 'blogcastr'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Clearance::Authentication
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def signed_in_as_blogcastr_user?
    !current_user.nil? && current_user.instance_of?(BlogcastrUser) 
  end
  
  def signed_in_as_facebook_user?
    !current_user.nil? && current_user.instance_of?(FacebookUser) 
  end

  def signed_in_as_twitter_user?
    !current_user.nil? && current_user.instance_of?(TwitterUser) 
  end

  #MVR - thrift
  #TODO: extract to library and add persistant connections
  def thrift_client
    return @thrift_client if defined?(@thrift_client)
    @thrift_socket = Thrift::Socket.new("192.168.1.3", 9090)
    #TODO: investigate multiple transports 
    @thrift_transport = Thrift::BufferedTransport.new(@thrift_socket)
    @thrift_transport.open
    @thrift_protocol = Thrift::BinaryProtocol.new(@thrift_transport)
    @thrift_client = Thrift::Blogcastr::Client.new(@thrift_protocol)
  end

  def thrift_client_close
    @thrift_transport.close if defined?(@thrift_transport)
  end
end
