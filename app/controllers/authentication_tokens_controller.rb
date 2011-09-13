class AuthenticationTokensController < ApplicationController
  def create
    @user = BlogcastrUser.authenticate(params[:username], params[:password])
    if @user.nil?
      respond_to do |format|
        format.xml { render :xml => "<errors><error>Authentication failed</error></errors>", :status => :forbidden }
        format.json { render :json => "[[\"Authentication failed\"]]", :status => :forbidden }
      end
      return
    end
    #AS DESIGNED: do not generate a new token per request
    if @user.authentication_token.nil?
      authentication_token = @user.generate_authentication_token(params[:password])
      @user.save
    else
      authentication_token = @user.authentication_token
    end
    @setting = @user.setting
    respond_to do |format|
      format.xml { render :template => 'share/new/user', :locals => { :user => @user, :setting => @setting, :show_authentication_token => true } }
    end
  end
end
