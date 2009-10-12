class Users::CommentsController < ApplicationController
  before_filter :set_time_zone

  def index
    #MVR - find user by name or id
    if !params[:user_name].nil?
      @user = BlogcastrUser.find_by_name(params[:user_name])
      if @user.nil?
        respond_to do |format|
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>Couldn't find BlogcastrUser with NAME=\"#{params[:user_name]}\"</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"Couldn't find BlogcastrUser with NAME=\"#{params[:user_name]}\"\"]]", :status => :unprocessable_entity}
        end
        return
      end
    else
      begin
        @user = BlogcastrUser.find(params[:user_id])
      rescue ActiveRecord::RecordNotFound => error
        respond_to do |format|
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>#{error.message}</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"#{error.message}\"]]", :status => :unprocessable_entity}
        end
        return
      end
    end
    respond_to do |format|
        format.html
        #TODO: limit result set and order by most recent 
        format.xml {render :xml => @user.comments.to_xml}
        format.json {render :json => @user.comments.to_json}
    end
  end
end
