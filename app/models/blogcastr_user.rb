class BlogcastrUser < User
  #MVR - email, password and password confirmation are set accessible by clearance
  attr_accessible :username, :has_facebook_publish_stream, :has_facebook_create_event
  validates_presence_of :username
  validates_uniqueness_of :username, :case_sensitive => false
  validate :valid_username?
  validate :valid_password?, :if => "password_required?"
  validate :unique_authentication_token?

  #MVR - added username support
  def self.authenticate(email, password)
    return nil unless user = find(:first, :conditions => ["LOWER(username) = ? OR LOWER(email) = ?", email.to_s.downcase, email.to_s.downcase])
    return user if user.authenticated?(password)
  end

  def get_username
    username
  end

  def get_url
    profile_path :username => username 
  end

  def get_facebook_username
    name = CACHE.get("SELECTnameFROMuserWHEREuid=" + facebook_id.to_s) 
    unless name
      name = Facebooker::Session.create.fql_query("SELECT name FROM user WHERE uid = " + facebook_id.to_s)[0].name
      CACHE.set("SELECTnameFROMuserWHEREuid=" + facebook_id.to_s, name, 1.day)
    end
    name
  end

  def get_facebook_url
    url = CACHE.get("SELECTprofile_urlFROMuserWHEREuid=" + facebook_id.to_s) 
    unless url
      url = Facebooker::Session.create.fql_query("SELECT profile_url FROM user WHERE uid = " + facebook_id.to_s)[0].profile_url
      CACHE.set("SELECTprofile_urlFROMuserWHEREuid=" + facebook_id.to_s, url, 1.day)
    end
    url
  end

  def get_facebook_avatar_url(size)
    avatar_url = CACHE.get("SELECTpic_square_with_logoFROMuserWHEREuid=" + facebook_id.to_s) 
    unless avatar_url 
      avatar_url = Facebooker::Session.create.fql_query("SELECT pic_square_with_logo FROM user WHERE uid = " + facebook_id.to_s)[0].pic_square_with_logo 
      CACHE.set("SELECTpic_square_with_logoFROMuserWHEREuid=" + facebook_id.to_s, avatar_url, 1.day)
    end
    avatar_url
  end

  def get_twitter_username
    screen_name = CACHE.get(id.to_s + "-screen_name") 
    unless screen_name 
      no_auth = Twitter::NoAuth::NoAuth.new()
      base = Twitter::Base.new(no_auth)
      screen_name = base.user(twitter_id).screen_name
      CACHE.set(twitter_id.to_s + "-screen_name", screen_name, 1.day)
    end
    screen_name
  end

  def get_twitter_avatar_url
    profile_image_url = CACHE.get(id.to_s + "-profile_image_url") 
    unless profile_image_url 
      no_auth = Twitter::NoAuth::NoAuth.new()
      base = Twitter::Base.new(no_auth)
      profile_image_url = base.user(twitter_id).profile_image_url
      CACHE.set(twitter_id.to_s + "-profile_image_url", profile_image_url, 1.day)
    end
    profile_image_url
  end

  protected

  #MVR - added authentication token
  def generate_authentication_token(password)
    self.authentication_token = encrypt("--#{Time.now.utc}--#{password}--")
  end

  #MVR - username must be between four and fifteen characters and can only contain alphanumeric characters and underscores
  def valid_username?
    if self.username.length < 4
        errors.add(:username, "must be at least 4 characters")
    elsif username.length > 15
        errors.add(:username, "must not be greater than 15 characters")
    end
    if self.username !~ /^[\w_]*$/
        errors.add(:username, "can only contain alphanumeric characters and underscores")
    end
  end

  #MVR - password must be at least 6 characters
  def valid_password?
    #MVR - only validate password on create
    if self.password.length < 6
        errors.add(:password, "must be at least 6 characters")
    end
  end

  #MVR - make sure authentication token is unique if set
  def unique_authentication_token?
    if !self.authentication_token.nil?
      if BlogcastrUser.find_by_authentication_token(authentication_token)
        errors.add(:authentication_token, "is already being used")
      end
    end
  end
end
