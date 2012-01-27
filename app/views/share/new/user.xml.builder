current_user = nil if !defined?(current_user)
subscription = nil if !defined?(subscription)
xml.user do
  xml.id(user.id)
  xml.type("BlogcastrUser")
  xml.username(user.username)
  xml.tag!("avatar-url", setting.avatar.url(:original))
  xml.tag!("full-name", setting.full_name)
  if !setting.location.blank?
    xml.location(setting.location)
  end
  if !setting.web.blank?
    xml.web(setting.web)
  end
  if !setting.bio.blank?
    xml.bio(setting.bio)
  end
  if user != current_user
    if subscription.nil?
      xml.subscription("false")
    else
      xml.subscription("true")
    end
  end
  #MVR - hide various private info if not current user 
  if user == current_user 
    xml.tag!("authentication-token", user.authentication_token)
  end
  if !user.facebook_full_name.blank? && !user.facebook_link.blank?
    xml.tag!("facebook-id", user.facebook_id)
    xml.tag!("facebook-full-name", user.facebook_full_name)
    xml.tag!("facebook-link", user.facebook_link)
    if user == current_user
      xml.tag!("facebook-access-token", user.facebook_access_token)
      xml.tag!("facebook-expires-at", user.facebook_expires_at.xmlschema)
      xml.tag!("has-facebook-publish-stream", user.has_facebook_publish_stream)
    end
  end
  if !user.twitter_username.blank?
    xml.tag!("twitter-username", user.twitter_username)
    if user == current_user
      xml.tag!("twitter-access-token", user.twitter_access_token)
      xml.tag!("twitter-token-secret", user.twitter_token_secret)
    end
  end
  xml.stats do
    xml.blogcasts(user.blogcasts.count)
    xml.subscriptions(user.subscriptions.count)
    xml.subscribers(user.subscribers.count)
    xml.posts(user.posts.count)
    xml.comments(user.comments.count)
    xml.likes(user.likes.count)
  end
  xml.tag!("created-at", user.created_at.xmlschema)
end
