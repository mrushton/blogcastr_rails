class BlogcastrUser < User
  attr_accessible :name
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_uniqueness_of :authentication_token

  #MVR - added user name support
  def self.authenticate(email, password)
    return nil unless user = find(:first, :conditions => ["name = ? OR email = ?", email.to_s.downcase, email.to_s.downcase])
    return user if user.authenticated?(password)
  end

  #MVR - added authentication token
  def generate_authentication_token(password)
    self.authentication_token = encrypt("--#{Time.now.utc}--#{password}--")
  end
end
