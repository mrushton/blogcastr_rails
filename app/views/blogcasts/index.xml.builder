xml.blogcasts do
  @blogcasts.each do |blogcast|
    xml.blogcast do
      xml.id(blogcast.id)
      xml.title(blogcast.title)
      xml.description(blogcast.description)
      xml.user do
        #MVR - we know this is always a BlogcastrUser
        user = blogcast.user
        xml.id(user.id)
        xml.type("BlogcastrUser")
        xml.username(user.username)
        xml.url(profile_url(:username => user.username))
        xml.tag!("avatar-url", user.setting.avatar.url(:original))
      end
      xml.tags do
        blogcast.tags.each do |tag|
          xml.tag(tag.name)
        end
      end
      image_post = blogcast.posts.find(:first, :conditions => "type = 'ImagePost'", :order => "id DESC")
      if !image_post.nil?
        #MVR - pass false to prevent updated timestamp from being included in the url 
        xml.tag!("image-url", image_post.image.url(:original, false))
        xml.tag!("image-width", image_post.image_width)
        xml.tag!("image-height", image_post.image_height)
      end
      xml.stats do
        #TODO: these rooms are created using an uppercase B but this needs to be lowercase
        current_viewers = @thrift_client.get_num_muc_room_occupants("blogcast." + blogcast.id.to_s)
        xml.tag!("current-viewers", current_viewers)
        xml.posts(blogcast.posts.count)
        xml.comments(blogcast.comments.count)
        xml.likes(blogcast.likes.count)
        xml.views(blogcast.views.count)
      end
      xml.tag!("starting-at", blogcast.starting_at.xmlschema)
      xml.tag!("created-at", blogcast.created_at.xmlschema)
      xml.tag!("updated-at", blogcast.updated_at.xmlschema)
    end
  end
end
