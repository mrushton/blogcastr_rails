class CommentsController < ApplicationController
  #MVR - needed to work around CSRF for REST api
  #TODO: add CSRF before filter for standard authentication only, other option is to modify Rails to bypass CSRF for certain user agents
  skip_before_filter :verify_authenticity_token
  before_filter :set_time_zone
  before_filter :only => [ "create" ] do |controller|
    #AS DESIGNED: check format because params array is not yet created
    if controller.request.format.html? || controller.request.format.js?
      controller.authenticate
    else 
      controller.rest_authenticate
    end
  end

  def index
    #MVR - find blogcast by id 
    begin 
      @blogcast = Blogcast.find(params[:blogcast_id])
    rescue
      respond_to do |format|
        format.xml { render :xml => "<errors><error>Couldn't find Blogcast with ID=\"#{params[:blogcast_id]}\"</error></errors>", :status => :unprocessable_entity }
        format.json { render :json => "[[\"Couldn't find Blogcast with ID=\"#{params[:blogcast_id]}\"\"]]", :status => :unprocessable_entity }
      end
      return
    end
    if params[:count].nil?
      count = 10
    else
      count = params[:count].to_i
      if count > 100
        count = 100
      end
    end
    if !params[:max_id].nil?
      max_id = params[:max_id].to_i
    end
    if (max_id.nil?)  
      @comments = @blogcast.comments.find(:all, :limit => count, :order => "id DESC")
    else
      @comments = @blogcast.comments.find(:all, :conditions => [ "id <= ?", max_id ], :limit => count, :order => "id DESC")
    end
    respond_to do |format|
      #TODO: limit result set and order by most recent
      format.xml { }
      format.json {
        if (max_id.nil?)  
          render :json => @user.comments.find(:all, :limit => count, :order => "id DESC").to_json(:only => [ :id, :title, :description, :starting_at, :updated_at, :name ], :include => :tags)
        else
          render :json => @user.comments.find(:all, :conditions => [ "id <= ?", max_id], :limit => count, :order => "id DESC").to_json(:only => [ :id, :title, :description, :starting_at, :updated_at, :name ], :include => :tags)
        end
      }
    end
  end

  def create
    if params[:authentication_token].nil?
      @user = current_user
    else 
      @user = rest_current_user
    end
    #MVR - find blogcast
    @blogcast = Blogcast.find(params[:blogcast_id]) 
    @comment = Comment.new(params[:comment])
    @comment.user_id = @user.id
    @comment.blogcast_id = @blogcast.id
    if !@comment.save
      respond_to do |format|
        format.js {@error = "Unable to save comment"; render :action => "error"}
        format.html {flash[:error] = "Unable to save comment"; redirect_to :back}
        format.xml {render :xml => @comment.errors.to_xml, :status => :unprocessable_entity}
        format.json {render :json => @comment.errors.to_json, :status => :unprocessable_entity}
      end
      return
    end
#    begin
      thrift_user = Thrift::User.new
      thrift_user.id = @user.id
      thrift_user.type = @user.class.to_s 
      if @user.instance_of?(BlogcastrUser)
        thrift_user.username = @user.username
        thrift_user.url = profile_path :username => @user.username
        thrift_user.avatar_url = @user.setting.avatar.url :original
      elsif @user.instance_of?(FacebookUser)
        thrift_user.username = @user.setting.full_name
        thrift_user.url = @user.facebook_link 
        thrift_user.avatar_url = @user.setting.avatar.url :original
      elsif @user.instance_of?(TwitterUser)
        thrift_user.username = "@" + @user.username
        thrift_user.url = "http://twitter.com/" + @user.username 
        thrift_user.avatar_url = @user.setting.avatar.url :original
      end
      thrift_comment = Thrift::Comment.new
      thrift_comment.id = @comment.id
      thrift_comment.created_at = @comment.created_at.xmlschema
      thrift_comment.from = @comment.from
      thrift_comment.text = @comment.text
      jid = params[:jid]
      #MVR - send to ejabberd
      err = thrift_client.send_comment_to_muc_room("Blogcast."+@blogcast.id.to_s, HOST, jid, thrift_user, thrift_comment)
      thrift_client_close
 #   rescue
 #     @comment.errors.add_to_base "Unable to post comment"
 #     @comment.destroy
 #     respond_to do |format|
 #       format.js {@error = "Unable to post comment"; render :action => "error"}
 #       format.html {flash[:error] = "Unable to send comment to muc room"; redirect_to :bacl}
 #       format.xml {render :xml => @comment.errors.to_xml, :status => :unprocessable_entity}
        #TODO: fix json support
 #       format.json {render :json => @comment.errors.to_json, :status => :unprocessable_entity}
 #     end
 #     return
 #   end
    respond_to do |format|
      format.js
      format.html {flash[:notice] = "Text post posted successfully"; redirect_to :back}
      format.xml {render :xml => @text_post.to_xml, :status => :created, :location => @text_post}
      format.json {render :json => @text_post.to_json, :status => :created, :location => @text_post}
    end
  end
end
