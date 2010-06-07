class SearchController < ApplicationController
  def index
    @user = current_user
    @query_params_results = {} 
    @query_params_order = {} 
    @query_params_time = {} 
    @query_params_field = {} 
    @query_params_paginate = {} 
    #MVR - if no query just return now
    if params[:query].blank?
      return
    end
    #AS DESIGNED: for the results parameters leave everything blank except query
    @query_params_results[:query] = params[:query]
    @query_params_order[:query] = params[:query]
    @query_params_time[:query] = params[:query]
    @query_params_field[:query] = params[:query]
    @query_params_paginate[:query] = params[:query]
    if !params[:results].blank?
      @query_params_order[:results] = params[:results]
      @query_params_time[:results] = params[:results]
      @query_params_field[:results] = params[:results]
      @query_params_paginate[:results] = params[:results]
    end
    if !params[:order_by].blank?
      @query_params_time[:order_by] = params[:order_by]
      @query_params_field[:order_by] = params[:order_by]
      @query_params_paginate[:order_by] = params[:order_by]
    end
    if !params[:time].blank?
      @query_params_order[:time] = params[:time]
      @query_params_field[:time] = params[:time]
      @query_params_paginate[:time] = params[:time]
    end
    if !params[:field].blank?
      @query_params_order[:field] = params[:field]
      @query_params_time[:field] = params[:field]
      @query_params_paginate[:field] = params[:field]
    end
    #MVR: escape all characters in the query syntax 
    query = params[:query].gsub(/[\+\-\&\|\!\(\)\{\}\[\]\^\"\~\*\?\:\\\;]/) {|s| "\\" + s}
    #TODO: is this the best way to handle AND, OR and NOT
    query = query.gsub(/AND|OR|NOT/) {|s| s.downcase}
    if params[:results] != "posts" && params[:results] != "comments"
      if params[:field] == "title"
        query = "title: (" + query + ")"
      elsif params[:field] == "tags"
        #TODO: investigate why acts_as_solr does not append the proper type for associations
        query = "tag_t: (" + query + ")"
      elsif params[:field] == "description"
        query = "description: (" + query + ")"
      end
    end
    #MVR - timestamp needs to be no larger than a long
    if (params[:timestamp].blank? || params[:timestamp] !~ /[0-9]+/ || params[:timestamp].to_i > 2147483647)
      #MVR - time needs to be in UTC
      @time = Time.now.utc
    else
      timestamp = params[:timestamp].to_i
      #MVR - time needs to be in UTC
      @time = Time.at(timestamp).utc
    end
    @query_params_paginate[:timestamp] = @time.to_i
    #MVR - acts_as_solr was patched to properly handle dates
    #MVR - time parameter filters blogcasts by starting_at and everything else by created_at
    if params[:results] != "posts" && params[:results] != "comments"
      if params[:time] == "next_24_hours"
        query = query + " AND starting_at:[" + @time.iso8601 + " TO " + (@time + 24.hours).iso8601 + "]"
      elsif params[:time] == "next_7_days"
        query = query + " AND starting_at:[" + @time.iso8601 + " TO " + (@time + 7.days).iso8601 + "]"
      elsif params[:time] == "next_30_days"
        query = query + " AND starting_at:[" + @time.iso8601 + " TO " + (@time + 30.days).iso8601 + "]"
      elsif params[:time] == "upcoming"
        query = query + " AND starting_at:[" + @time.iso8601 + " TO *]"
      elsif params[:time] == "last_24_hours"
        query = query + " AND starting_at:[" + (@time - 24.hours).iso8601 + " TO " + @time.iso8601  + "]"
      elsif params[:time] == "last_7_days"
        query = query + " AND starting_at:[" + (@time - 7.days).iso8601 + " TO " + @time.iso8601  + "]"
      elsif params[:time] == "last_30_days"
        query = query + " AND starting_at:[" + (@time - 30.days).iso8601 + " TO " + @time.iso8601  + "]"
      elsif params[:time] == "past"
        query = query + " AND starting_at:[* TO " + @time.iso8601  + "]"
      end
      query = query + " AND created_at:[* TO " + @time.iso8601 + "]"
    else
      if params[:time] == "last_24_hours"
        query = query + " AND created_at:[" + (@time - 24.hours).iso8601 + " TO " + @time.iso8601  + "]"
      elsif params[:time] == "last_7_days"
        query = query + " AND created_at:[" + (@time - 7.days).iso8601 + " TO " + @time.iso8601  + "]"
      elsif params[:time] == "last_30_days"
        query = query + " AND created_at:[" + (@time - 30.days).iso8601 + " TO " + @time.iso8601  + "]"
      else
        query = query + " AND created_at:[* TO " + @time.iso8601 + "]"
      end
    end
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
