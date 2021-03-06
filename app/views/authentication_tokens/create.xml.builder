xml.user do
  xml.id(@user.id)
  xml.type("BlogcastrUser")
  xml.username(@user.username)
  xml.tag!("avatar-url", @setting.avatar.url(:original))
  xml.tag!("full-name", @setting.full_name)
  if !@setting.location.blank?
    xml.location(@setting.location)
  end
  if !@setting.web.blank?
    xml.web(@setting.web)
  end
  if !@setting.bio.blank?
    xml.bio(@setting.bio)
  end
  xml.tag!("authentication-token", @user.authentication_token)
  xml.stats do
    xml.blogcasts(@user.blogcasts.count)
    xml.subscriptions(@user.subscriptions.count)
    xml.subscribers(@user.subscribers.count)
    xml.posts(@user.posts.count)
    xml.comments(@user.comments.count)
    xml.likes(@user.likes.count)
  end
  xml.tag!("created-at", @user.created_at.xmlschema)
end
