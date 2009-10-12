class TextPostsController < ApplicationController
  before_filter do |controller|
    if controller.request.format.html?
      controller.authenticate
    else 
      controller.rest_authenticate
    end
  end

  def create
    if request.format.html?
      @user = current_user
    else 
      @user = rest_current_user
    end
    @blogcast = @user.blogcasts.find(params[:blogcast_id]) 
    @text_post = TextPost.new(params[:text_post])
    @text_post.blogcast_id = @blogcast.id
    @text_post.user_id = @user.id
    begin
      @text_post.save
    rescue ActiveRecord::StatementInvalid => error
      respond_to do |format|
        format.html {render :file => "public/404.html", :layout => false, :status => 404}
        format.xml {render :xml => "<errors><error>#{error.message}</error></errors>", :status => :unprocessable_entity}
        format.json {render :json => "[[\"#{error.message}\"]]", :status => :unprocessable_entity}
      end
      return
    end
    thrift_user = Thrift::User.new
    thrift_user.name = @user.name
    thrift_user.account = "Blogcastr"
    thrift_user.url = profile_path :username => @user.name
    thrift_user.avatar_url = @user.setting.avatar.url(:medium)
    thrift_text_post = Thrift::TextPost.new
    thrift_text_post.id = @text_post.id
    thrift_text_post.timestamp = @text_post.created_at.to_i
    thrift_text_post.medium = @text_post.from
    thrift_text_post.text = @text_post.text
    #MVR - send text post to muc room and pubsub node
    err = thrift_client.send_text_post_to_muc_room(@user.name, @user.name + ".blog", thrift_user, thrift_text_post)
    #err = thrift_client.publish_text_post_to_pubsub_node(@user.login, "/home/blogcastr.com/" + @user.login + "/blog", text_text_post)
    thrift_client_close
    #TODO: gracefully handle errors or no javascript support
    render :nothing => true
  end
end
