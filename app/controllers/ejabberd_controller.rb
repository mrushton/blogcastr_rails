class EjabberdController < ApplicationController
  before_filter do |controller|
    if controller.request.format.js?
      controller.authenticate
    else 
      controller.rest_authenticate
    end
  end

  def password
    if request.format.js?
      @user = current_user
    else 
      @user = rest_current_user
    end
    #MVR - get password from ejabberd
    #TODO: error handling
    @password = thrift_client.get_user_password(@user.name)
    thrift_client_close
    respond_to do |format|
      format.js
      format.xml {render :xml => "<password>#{@password}</password>"}
      format.json {render :json => "[[\"#{@password}\"]]"}
    end
  end
end
