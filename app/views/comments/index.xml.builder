xml.comments do
  @comments.each do |comment|
    xml.comment do
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
      xml.tag!("created-at", comment.created_at.xmlschema)
      xml.tag!("updated-at", comment.updated_at.xmlschema)
    end
  end
end
