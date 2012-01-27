xml.posts do
  @posts.each do |post|
    xml.post do
      xml.id(post.id)
      xml.type(post.type)
      #MVR - we know this is always a BlogcastrUser
      user = post.user
      xml.user do
        xml.id(user.id)
        xml.type(user.type)
        xml.username(user.username)
        xml.url(profile_url(:username => user.username))
        xml.tag!("avatar-url", user.setting.avatar.url(:original))
      end
      #MVR - work around for a strange object loading issue where type is not a String unless from comes first 
      post.from
      #MVR - handle each post type differently
      if (post.type == "TextPost")
        xml.text(post.text) 
      elsif (post.type == "ImagePost")
        #MVR - pass false to prevent updated timestamp from being included in the url 
        xml.tag!("image-url", post.image.url(:original, false))
        if !post.text.blank?
          xml.text(post.text)
        end
        xml.tag!("image-width", post.image_width)
        xml.tag!("image-height", post.image_height)
      elsif (post.type == "CommentPost")
        xml.comment do
          comment = post.comment
          xml.id(comment.id)
          xml.user do
            user = comment.user
            xml.id(user.id)
            xml.type(user.type)
            if user.instance_of?(BlogcastrUser)
              xml.username(user.username)
              xml.url(profile_url(:username => user.username))
            elsif user.instance_of?(FacebookUser)
              xml.username(user.setting.full_name)
              xml.url(user.facebook_link)
            elsif user.instance_of?(TwitterUser)
              xml.username(user.username)
              xml.url("http://twitter.com/" + user.username)
            end
            xml.tag!("avatar-url", user.setting.avatar.url(:original))
          end
          xml.text(comment.text)
          xml.from(comment.from)
          xml.tag!("created-at", comment.created_at.xmlschema) 
          xml.tag!("updated-at", comment.created_at.xmlschema)
        end
      end
      xml.from(post.from)
      blogcast = post.blogcast
      xml.url(blogcast_post_permalink_url(:username => user.username, :year => blogcast.year, :month => blogcast.month, :day => blogcast.day, :title => blogcast.link_title, :post_id => post.id)) 
      if !post.short_url.blank?
        xml.tag!("short-url", post.short_url)
      end
      xml.tag!("created-at", post.created_at.xmlschema)
      xml.tag!("updated-at", post.updated_at.xmlschema)
    end
  end
end
