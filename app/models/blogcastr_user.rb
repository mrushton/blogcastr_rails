class BlogcastrUser < User
  attr_accessible :name
  validates_presence_of :name
  validates_uniqueness_of :name

  #MVR - added user name support
  def self.authenticate(email, password)
    return nil unless user = find(:first, :conditions => ["name = ? OR email = ?", email.to_s.downcase, email.to_s.downcase])
    return user if user.authenticated?(password)
  end
end
