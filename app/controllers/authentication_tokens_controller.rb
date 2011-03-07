class AuthenticationTokensController < ApplicationController
  def create
    @user = BlogcastrUser.authenticate(params[:username], params[:password])
    if @user.nil?
      respond_to do |format|
        format.xml { render :xml => "<errors><error>Authentication failed</error></errors>", :status => :forbidden }
        format.json { render :json => "[[\"Authentication failed\"]]", :status => :forbidden }
      end
      return
    else
      if !@user.email_confirmed?
        respond_to do |format|
          format.xml { render :xml => "<errors><error>Email not confirmed</error></errors>", :status => :unprocessable_entity }
          format.json { render :json => "[[\"Email not confirmed\"]]", :status => :unprocessable_entity }
        end
        return
      else
        #AS DESIGNED: do not generate a new token per request
        if @user.authentication_token.nil?
          authentication_token = @user.generate_authentication_token(params[:password])
          @user.save
        else
          authentication_token = @user.authentication_token
        end
        respond_to do |format|
          format.xml { render :xml => @user.to_xml(:only => [ :id, :username, :authentication_token, :created_at, :updated_at ], :include => { :setting => { :only => [ :full_name, :location, :web, :bio ] } }) }
          format.json { render :json => @user.to_json(:only => [ :id, :username, :authentication_token, :created_at, :updated_at ], :include => { :setting => { :only => [ :full_name, :location, :web, :bio ] } }) }
        end
        return
      end
    end
  end
end
