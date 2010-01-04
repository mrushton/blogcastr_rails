class Setting < ActiveRecord::Base
  belongs_to :user
  #MVR - store in either s3 or locally on file
  if Rails.env.production?
    has_attached_file :avatar, :styles => {:large => "200x200#", :medium => "80x80#", :small => "30x30#"}, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :path => ":attachment/:id/:style/:basename.:extension"
    has_attached_file :background, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :path => ":attachment/:id/:style/:basename.:extension"
  else
    has_attached_file :avatar, :styles => {:large => "200x200#", :medium => "80x80#", :small => "30x30#"}
    has_attached_file :background
  end
end
