module PostsHelper
  def overlay_post_content_div
    if @post.instance_of?(ImagePost)
      if @post.image_height > 600
        image_width = @post.image_width.to_f / @post.image_height.to_f * 600.0
      else
        image_width = @post.image_width
      end
      #MVR - do not let image get too large 
      if image_width > 860
        image_width = 860
      end 
      "<div id=\"overlay-post-content\" style=\"width: #{image_width}px;\">"
    else
      "<div id=\"overlay-post-content\">"
    end
  end
end
