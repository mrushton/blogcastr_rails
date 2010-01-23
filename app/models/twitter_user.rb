class TwitterUser < User 
  def get_username
    screen_name = CACHE.get(id.to_s + "-screen_name") 
    unless screen_name 
      no_auth = Twitter::NoAuth::NoAuth.new()
      base = Twitter::Base.new(no_auth)
      screen_name = base.user(twitter_id).screen_name
      CACHE.set(twitter_id.to_s + "-screen_name", screen_name, 1.day)
    end
    screen_name
  end

  def get_url
    screen_name = CACHE.get(id.to_s + "-screen_name") 
    unless screen_name 
      no_auth = Twitter::NoAuth::NoAuth.new()
      base = Twitter::Base.new(no_auth)
      screen_name = base.user(twitter_id).screen_name
      CACHE.set(twitter_id.to_s + "-screen_name", screen_name, 1.day)
    end
    "http://twitter.com/" + screen_name
  end

  def get_avatar_url(size)
    profile_image_url = CACHE.get(id.to_s + "-profile_image_url") 
    unless profile_image_url 
      no_auth = Twitter::NoAuth::NoAuth.new()
      base = Twitter::Base.new(no_auth)
      profile_image_url = base.user(twitter_id).profile_image_url
      CACHE.set(twitter_id.to_s + "-profile_image_url", profile_image_url, 1.day)
    end
    profile_image_url
  end
end
