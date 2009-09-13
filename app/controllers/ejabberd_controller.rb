class EjabberdController < ApplicationController
  #TODO: don't really want to do this want to return an error
  before_filter :authenticate

  def password
    @user = current_user
    #MVR - get password from ejabberd
    #TODO: error handling
    @password = thrift_client.get_user_password(@user.name)
    thrift_client_close
  end
end
