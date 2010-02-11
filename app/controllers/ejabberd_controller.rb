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
    begin
      @password = thrift_client.get_user_password(@user.username, HOST)
      thrift_client_close
    rescue
      respond_to do |format|
        format.js
        format.xml {render :xml => "<errors><error>Internal server error</error></errors>"}
        format.json {render :json => "[[\"Internal server error\"]]"}
      end
      return
    end
    respond_to do |format|
      format.js
      format.xml {render :xml => "<password>#{@password}</password>"}
      format.json {render :json => "[[\"#{@password}\"]]"}
    end
  end
end
