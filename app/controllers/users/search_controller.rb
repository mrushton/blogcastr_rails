class Users::SearchController < ApplicationController
  def index
    @user = current_user
    #MVR - find user by username
    @profile_user = BlogcastrUser.find_by_username(params[:username])
    if @profile_user.nil?
      render :file => "public/404.html", :layout => false, :status => 404
      return
    end
    #MVR - blogcasts
    @num_blogcasts = @profile_user.blogcasts.count
    #MVR - comments
    @num_comments = @profile_user.comments.count 
    #MVR - likes 
    @num_likes = Like.count(:conditions => {:user_id => @profile_user.id})
    #MVR - subscriptions
    @subscriptions = User.find_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.user_id = ? AND subscriptions.subscribed_to = users.id LIMIT 16", @profile_user.id])
    @num_subscriptions = @profile_user.subscriptions.count
    #MVR - subscribers
    @subscribers = User.find_by_sql(["SELECT users.* FROM subscriptions, users WHERE subscriptions.subscribed_to = ? AND subscriptions.user_id = users.id LIMIT 16", @profile_user.id])
    @num_subscribers = @profile_user.subscribers.count
    #MVR - posts
    @num_posts = @profile_user.posts.count
    @profile_user_username_possesive = @profile_user.username + (@profile_user.username =~ /.*s$/ ? "'":"'s")
    @profile_user_username_possesive_escaped = @profile_user_username_possesive.gsub(/'/,"\\\\\'")
    @query_params_results = {} 
    @query_params_order = {} 
    @query_params_paginate = {} 
    #MVR - if no query just return now
    if params[:query].blank?
      return
    end
    #AS DESIGNED: for the results parameters leave everything blank except username and query
    @query_params_results[:username] = @profile_user.username
    @query_params_order[:username] = @profile_user.username 
    @query_params_paginate[:username] = @profile_user.username 
    @query_params_results[:query] = params[:query]
    @query_params_order[:query] = params[:query]
    @query_params_paginate[:query] = params[:query]
    if !params[:results].blank?
      @query_params_order[:results] = params[:results]
      @query_params_paginate[:results] = params[:results]
    end
    if !params[:order_by].blank?
      @query_params_paginate[:order_by] = params[:order_by]
    end
    #MVR - escape all characters in the query syntax 
    query = params[:query].gsub(/[\+\-\&\|\!\(\)\{\}\[\]\^\"\~\*\?\:\\\;]/) {|s| "\\" + s}
    #TODO: is this the best way to handle AND, OR and NOT
    query = query.gsub(/AND|OR|NOT/) {|s| s.downcase}
    query = query + " user_id: (" + @profile_user.id.to_s + ")"
    #MVR - timestamp needs to be no larger than a long
    if (params[:timestamp].blank? || params[:timestamp] !~ /[0-9]+/ || params[:timestamp].to_i > 2147483647)
      #MVR - time needs to be in UTC
      @time = Time.now.utc
    else
      timestamp = params[:timestamp].to_i
      #MVR - time needs to be in UTC
      @time = Time.at(timestamp).utc
    end
    @query_params_paginate[:username] = @profile_user.username
    @query_params_paginate[:timestamp] = @time.to_i
    options = {}
    if !params[:page].blank?
      @page = params[:page].to_i
      if @page > 1 
        @previous_page = @page - 1
      end
      options[:limit] = 10 
      options[:offset] = (@page - 1) * 10
      @num_first_result = options[:offset] + 1
    else
      @page = 1
      @num_first_result = 1 
    end
    if (params[:results] == "posts")
      #MVR - most relevant is the default
      if params[:order_by] != "most_relevant"
        options[:order] = "created_at desc"
      end
      #AS DESIGNED: work around for acts_as_solr not being great with single table inheritance
      options[:models] = [TextPost, ImagePost, AudioPost, CommentPost]
      @posts = Post.multi_solr_search(query, options)
      @num_results = @posts.total
    elsif (params[:results] == "comments")
      #MVR - most relevant is the default
      if params[:order_by] != "most_relevant"
        options[:order] = "created_at desc"
      end
      @comments = Comment.find_by_solr(query, options)
      @num_results = @comments.total
    else
      #MVR - relevant is the default
      if (params[:order_by] == "starting_at")
        options[:order] = "starting_at desc"
      elsif (params[:order_by] != "most_relevant")
        options[:order] = "created_at desc"
      end
      @blogcasts = Blogcast.find_by_solr(query, options)
      @num_results = @blogcasts.total
    end
    @num_last_result = @page * 10 
    if @num_last_result > @num_results
        @num_last_result = @num_results
    end
    if @page * 10 < @num_results
      @next_page = @page + 1
    end
  end
end
