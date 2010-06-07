class Users::Blogcasts::CommentsController < ApplicationController
  before_filter :set_time_zone

  def index

    if !params[:username].nil?
      @blogcast_user = BlogcastrUser.find_by_username(params[:username])
      if @blogcast_user.nil?
        respond_to do |format|
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>Couldn't find BlogcastrUser with NAME=\"#{params[:username]}\"</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"Couldn't find BlogcastrUser with NAME=\"#{params[:username]}\"\"]]", :status => :unprocessable_entity}
        end
        return
      end
    else
      respond_to do |format|
        format.html {render :file => "public/404.html", :layout => false, :status => 404}
        format.xml {render :xml => "<errors><error>#{error.message}</error></errors>", :status => :unprocessable_entity}
        format.json {render :json => "[[\"#{error.message}\"]]", :status => :unprocessable_entity}
      end
      return
    end
    if !params[:year].nil? && !params[:month].nil? && !params[:day].nil? && !params[:title].nil?
      @blogcast = @blogcast_user.blogcasts.find(:first, :conditions => {:year => params[:year].to_i, :month => params[:month].to_i, :day => params[:day].to_i, :link_title => params[:title]})
      if @blogcast.nil?
        respond_to do |format|
          #TODO: better error messages
          format.html {render :file => "public/404.html", :layout => false, :status => 404}
          format.xml {render :xml => "<errors><error>Couldn't find Blogcast</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[\"Couldn't find Blogcast\"]]", :status => :unprocessable_entity}
        end
        return
      end
    else
      respond_to do |format|
        format.html {render :file => "public/404.html", :layout => false, :status => 404}
        format.xml {render :xml => "<errors><error>#{error.message}</error></errors>", :status => :unprocessable_entity}
        format.json {render :json => "[[\"#{error.message}\"]]", :status => :unprocessable_entity}
      end
    end
    #MVR - paginated comments 
    if params[:page].nil?
      @page = 1 
    else
      @page = params[:page].to_i
    end
    if !params[:id].nil?
      @id = params[:id].to_i
    end
    if @id.blank?
      @paginated_comments = Comment.paginate_by_sql(["SELECT * FROM comments WHERE blogcast_id = ?", @blogcast.id], :page => @page, :per_page => 10)
      @id = Comment.maximum(:id, :conditions => ["blogcast_id = ?", @blogcast.id])
    else
      @paginated_comments = Comment.paginate_by_sql(["SELECT * FROM comments WHERE blogcast_id = ? AND id <= ?", @blogcast.id, @id], :page => @page, :per_page => 10)
    end
    @num_paginated_comments = Comment.count(:conditions => ["blogcast_id = ? AND id <= ?", @blogcast.id, @id])
    if @page * 10 < @num_paginated_comments
      @next_page = @page + 1
    end
    @num_first_comment = ((@page - 1) * 10) + 1
    @num_last_comment = @page * 10 
    if @num_last_comment > @num_paginated_comments
      @num_last_comment = @num_paginated_comments
    end
    respond_to do |format|
        format.html do
          #MVR - get settings
          @blogcast_setting = @blogcast_user.setting
          @user = current_user
          #MVR - posts 
          @posts = @blogcast.posts.find(:all, :order => "created_at DESC") 
          @num_posts = @blogcast.posts.count
          #MVR - comments
          @num_comments = @blogcast.comments.count
          #TODO: live viewers
          @num_viewers = 0
          #MVR - create view
          if !@user.nil?
            @blogcast.views.create :user_id => @user.id;
          else
            @blogcast.views.create;
          end
          @num_views = @blogcast.views.count
          #TODO: do not use find_by_sql
          @likes = User.find_by_sql(["SELECT users.* FROM likes, users WHERE likes.blogcast_id = ? AND likes.user_id = users.id LIMIT 21", @blogcast.id])
          @num_likes = @blogcast.likes.count 
          @blogcast_username_possesive = @blogcast_user.username + (@blogcast_user.username =~ /.*s$/ ? "'":"'s")
          @tweet_url = "http://twitter.com/home?status=%22" + @blogcast.title + "%22%20by%20" + @blogcast_user.username + ".%20" + username_blogcast_permalink_url(:username => @blogcast_user.username, :year => @blogcast.year, :month => @blogcast.month, :day => @blogcast.day, :title => @blogcast.link_title)
          if @user.instance_of?(BlogcastrUser)
            @email_blogcast_reminder = EmailBlogcastReminder.find(:first, :conditions => ["user_id = ? AND blogcast_id = ?", @user.id, @blogcast.id])
            @sms_blogcast_reminder = SmsBlogcastReminder.find(:first, :conditions => ["user_id = ? AND blogcast_id = ?", @user.id, @blogcast.id])
          end
          #MVR - subscribers
          @num_subscribers = @blogcast_user.subscribers.count
          #MVR - subscriptions
          @num_subscriptions = @blogcast_user.subscriptions.count
          #MVR - blogcasts
          @num_blogcasts = @blogcast_user.blogcasts.count
          #MVR - subscriptions
          if @blogcast_setting.use_background_image == false
            @theme = @blogcast_setting.theme
          end
          render :layout => "users/blogcasts"
        end
        #TODO: limit result set and order by most recent 
        format.xml {render :xml => @blogcast.to_xml(:include => :posts)}
        format.json {render :json => @blogcast.to_json(:include => :posts)}
    end
    return













  end
end
