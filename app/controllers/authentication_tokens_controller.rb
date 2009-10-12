class AuthenticationTokensController < ApplicationController
  def create
    @user = BlogcastrUser.authenticate(params[:user_name], params[:password])
    if @user.nil?
      respond_to do |format|
        format.xml {render :xml => "<errors><error>Authentication failed</error></errors>", :status => :unprocessable_entity}
        format.json {render :json => "[[\"Authentication failed\"]]", :status => :unprocessable_entity}
      end
      return
    else
      if !@user.email_confirmed?
        respond_to do |format|
          format.xml {render :xml => "<errors><error>Email not confirmed</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"Email not confirmed\"]]", :status => :unprocessable_entity}
        end
        return
      else
        authentication_token = @user.generate_authentication_token(params[:password])
        @user.save
        respond_to do |format|
          format.xml {render :xml => "<authentication_token>#{authentication_token}</authentication_token>"}
          format.json {render :json => "[[\"#{authentication_token}\"]]"}
        end
        return
      end
    end
  end
end
