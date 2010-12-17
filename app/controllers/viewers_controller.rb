class ViewersController < ApplicationController
  def update_current_viewers
    @blogcast = Blogcast.find(params[:blogcast_id])
    if @blogcast.nil?
      respond_to do |format|
        format.js {@error = "Unable to update number of viewers."; render :action => "error"}
        #TODO: fix xml and json support
        format.xml {render :xml => @blogcast.errors.to_xml, :status => :unprocessable_entity}
        format.json {render :json => @blogcast.errors.to_json, :status => :unprocessable_entity}
      end
      return
    end
    begin
    #num_viewers = CACHE.get("Blogcast:" + id.to_s + "-num_viewers") 
    #unless num_viewers 
      #CACHE.set("Blogcast:" + id.to_s + "-num_viewers", num_viewers, 30.seconds)
   # end
   #TODO: these rooms are created using an uppercase B but this needs to be lowercase
      @num_viewers = thrift_client.get_num_muc_room_occupants("blogcast." + @blogcast.id.to_s) + 1
      thrift_client_close
    rescue
      @num_viewers = 1 
    end
    respond_to do |format|
      format.js {}
      #TODO: fix xml and json support
      format.xml {render :xml => @blogcast.errors.to_xml, :status => :unprocessable_entity}
      format.json {render :json => @blogcast.errors.to_json, :status => :unprocessable_entity}
    end
  end
end
