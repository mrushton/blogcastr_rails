class FacebookUser < User
  def get_username
    name = CACHE.get("SELECTnameFROMuserWHEREuid=" + facebook_id.to_s) 
    unless name
      name = Facebooker::Session.create.fql_query("SELECT name FROM user WHERE uid = " + facebook_id.to_s)[0].name
      CACHE.set("SELECTnameFROMuserWHEREuid=" + facebook_id.to_s, name, 1.day)
    end
    name
  end

  def get_url
    url = CACHE.get("SELECTprofile_urlFROMuserWHEREuid=" + facebook_id.to_s) 
    unless url
      url = Facebooker::Session.create.fql_query("SELECT profile_url FROM user WHERE uid = " + facebook_id.to_s)[0].profile_url
      CACHE.set("SELECTprofile_urlFROMuserWHEREuid=" + facebook_id.to_s, url, 1.day)
    end
    url
  end

  def get_avatar_url(size)
    avatar_url = CACHE.get("SELECTpic_square_with_logoFROMuserWHEREuid=" + facebook_id.to_s) 
    unless avatar_url 
      avatar_url = Facebooker::Session.create.fql_query("SELECT pic_square_with_logo FROM user WHERE uid = " + facebook_id.to_s)[0].pic_square_with_logo 
      CACHE.set("SELECTpic_square_with_logoFROMuserWHEREuid=" + facebook_id.to_s, avatar_url, 1.day)
    end
    avatar_url
  end
end
