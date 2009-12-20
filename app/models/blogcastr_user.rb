class BlogcastrUser < User
  #MVR - email, password and password confirmation are set accessible by clearance
  attr_accessible :name
  validates_presence_of :name
  validates_uniqueness_of :name
  validate :unique_authentication_token?

  #MVR - added user name support
  def self.authenticate(email, password)
    return nil unless user = find(:first, :conditions => ["name = ? OR email = ?", email.to_s.downcase, email.to_s.downcase])
    return user if user.authenticated?(password)
  end

  #MVR - added authentication token
  def generate_authentication_token(password)
    self.authentication_token = encrypt("--#{Time.now.utc}--#{password}--")
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
