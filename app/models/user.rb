class User < ActiveRecord::Base
  include Clearance::User

  has_many :blogcasts
  has_one :setting
  has_many :posts
  has_many :comments
  has_many :subscriptions
  has_many :subscribers, :class_name => "Subscription", :foreign_key => "subscribed_to" 
  has_many :likes

  #TODO: refactor this
  def get_user_name
    if instance_of?(BlogcastrUser)
      name
    elsif instance_of?(FacebookUser)
      name = CACHE.get("SELECTnameFROMuserWHEREuid=" + facebook_id.to_s) 
      unless name
        name = Facebooker::Session.create.fql_query("SELECT name FROM user WHERE uid = " + facebook_id.to_s)[0].name
        CACHE.set("SELECTnameFROMuserWHEREuid=" + facebook_id.to_s, name, 1.day)
      end
      name
    elsif instance_of?(TwitterUser)
      screen_name = CACHE.get(id.to_s + "-screen_name") 
      unless screen_name 
        no_auth = Twitter::NoAuth::NoAuth.new()
        base = Twitter::Base.new(no_auth)
        screen_name = base.user(twitter_id).screen_name
        CACHE.set(id.to_s + "-screen_name", screen_name, 1.day)
      end
      screen_name
    else
    end
  end

  def get_user_url
    if instance_of?(BlogcastrUser)
      #MVR - it looks like objects don't get helpers so can't use blogast_path
      "/" + name 
    elsif instance_of?(FacebookUser)
      url = CACHE.get("SELECTprofile_urlFROMuserWHEREuid=" + facebook_id.to_s) 
      unless url
        url = Facebooker::Session.create.fql_query("SELECT profile_url FROM user WHERE uid = " + facebook_id.to_s)[0].profile_url
        CACHE.set("SELECTprofile_urlFROMuserWHEREuid=" + facebook_id.to_s, url, 1.day)
      end
      url
    elsif instance_of?(TwitterUser)
      screen_name = CACHE.get(id.to_s + "-screen_name") 
      unless screen_name 
        no_auth = Twitter::NoAuth::NoAuth.new()
        base = Twitter::Base.new(no_auth)
        screen_name = base.user(twitter_id).screen_name
        CACHE.set(id.to_s + "-screen_name", screen_name, 1.day)
      end
      "http://twitter.com/" + screen_name
    else
    end
  end

  def get_user_avatar_url(size)
    if instance_of?(BlogcastrUser)
      setting.avatar.url(size)
    elsif instance_of?(FacebookUser)
      avatar_url = CACHE.get("SELECTpic_square_with_logoFROMuserWHEREuid=" + facebook_id.to_s) 
      unless avatar_url 
        avatar_url = Facebooker::Session.create.fql_query("SELECT pic_square_with_logo FROM user WHERE uid = " + facebook_id.to_s)[0].pic_square_with_logo 
        CACHE.set("SELECTpic_square_with_logoFROMuserWHEREuid=" + facebook_id.to_s, avatar_url, 1.day)
      end
      avatar_url
    elsif instance_of?(TwitterUser)
      avatar_url = CACHE.get(id.to_s + "-avatar_url") 
      unless avatar_url 
        no_auth = Twitter::NoAuth::NoAuth.new()
        base = Twitter::Base.new(no_auth)
        avatar_url = base.user(twitter_id).profile_image_url
        CACHE.set(id.to_s + "-avatar_url", avatar_url, 1.day)
      end
      avatar_url
    else
    end
  end

  def get_user_avatar_class(size)
    if instance_of?(BlogcastrUser)
      if size == :small
        "avatar-small-rounded"
      elsif size == :medium
        "avatar-medium-rounded"
      elsif size == :large
        "avatar-large-rounded"
      end
    elsif instance_of?(FacebookUser)
      if size == :small
        "facebook-avatar-small-rounded"
      elsif size == :medium
        "facebook-avatar-medium-rounded"
      elsif size == :large
        "facebook-avatar-large-rounded"
      end
    elsif instance_of?(TwitterUser)
      if size == :small
        "twitter-avatar-small-rounded"
      elsif size == :medium
        "twitter-avatar-medium-rounded"
      elsif size == :large
        "twitter-avatar-large-rounded"
      end
    end
  end
end
