class Setting < ActiveRecord::Base
  belongs_to :user
  has_attached_file :avatar, :styles => {:large => "100x100#", :medium => "80x80#", :small => "20x20#"}, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :path => ":attachment/:id/:style/:basename.:extension"
  has_attached_file :background, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :path => ":attachment/:id/:style/:basename.:extension"
end
