class BlogcastrUser < User
  #MVR - email, password and password confirmation are set accessible by clearance
  attr_accessible :username
  validates_presence_of :username
  validates_uniqueness_of :username, :case_sensitive => false
  validate :valid_username?
  validate :valid_password?
  validate :unique_authentication_token?

  #MVR - added username support
  def self.authenticate(email, password)
    return nil unless user = find(:first, :conditions => ["username = ? OR email = ?", email.to_s.downcase, email.to_s.downcase])
    return user if user.authenticated?(password)
  end

  def get_username
    username
  end

  def get_url
    profile_path :username => username 
  end

  protected

  #MVR - added authentication token
  def generate_authentication_token(password)
    self.authentication_token = encrypt("--#{Time.now.utc}--#{password}--")
  end

  #MVR - username must be between four and fifteen characters and can only contain alphanumeric characters and underscores
  def valid_username?
    if username.length < 4
        errors.add(:username, "must be at least 4 characters")
    elsif username.length > 15
        errors.add(:username, "must not be greater than 15 characters")
    end
    if username !~ /^[\w_]*$/
        errors.add(:username, "can only contain alphanumeric characters and underscores")
    end
  end

  #MVR - password must be at least 6 characters
  def valid_password?
    if password.length < 6
        errors.add(:password, "must be at least 6 characters")
    end
  end

  #MVR - make sure authentication token is unique if set
  def unique_authentication_token?
    if !authentication_token.nil?
      if BlogcastrUser.find_by_authentication_token(authentication_token)
        errors.add(:authentication_token, "is already being used")
      end
    end
  end
end
