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
    @num_viewers = @blogcast.get_num_viewers 
    respond_to do |format|
      format.js {}
      #TODO: fix xml and json support
      format.xml {render :xml => @blogcast.errors.to_xml, :status => :unprocessable_entity}
      format.json {render :json => @blogcast.errors.to_json, :status => :unprocessable_entity}
    end
  end
end
