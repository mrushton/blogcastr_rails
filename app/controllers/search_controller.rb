class SearchController < ApplicationController
  def index
    respond_to do |format|
      begin
        if (params[:query].nil?)
          format.html {}
          format.xml {render :xml => "<errors><error>Query undefined</error></errors>", :status => :unprocessable_entity}
          format.json {render :json => "[[Query undefined]]", :status => :unprocessable_entity}
          return
        end  
        if (params[:type] == "Posts")
          @type = "Posts"
        elsif (params[:type] == "Comments")
          @type = "Comments"
        else
          @type = "Blogcasts"
          @blogcasts = Blogcast.find_by_solr(params[:query])
        end
        
        format.html {}
        format.xml {render :xml => @blogcasts.to_xml}
        format.json {render :json => @blogcasts.to_json}
      rescue ActiveRecord::RecordNotFound => error
        format.html {render :file => "public/404.html", :layout => false, :status => 404}
        format.xml {render :xml => "<errors><error>#{error.message}</error></errors>", :status => :unprocessable_entity}
        format.json {render :json => "[[#{error.message}]]", :status => :unprocessable_entity}
      end
    end
  end
end
