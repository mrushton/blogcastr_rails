class Setting < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :full_name
  #MVR - store in either s3 or locally on file
  if Rails.env.production?
    has_attached_file :avatar, :styles => {:large => "200x200#", :medium => "80x80#", :small => "30x30#"}, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :path => ":attachment/:id/:style/:basename.:extension"
    has_attached_file :background, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :path => ":attachment/:id/:style/:basename.:extension"
  else
    has_attached_file :avatar, :styles => {:large => "200x200#", :medium => "80x80#", :small => "30x30#"}
    has_attached_file :background_image
  end
  #MVR - paperclip validations need to come after has_attached_file
  #MVR - IE uses non-standard content types for jpeg and png.
  validates_attachment_content_type :avatar, :content_type => ["image/jpeg", "image/pjpeg", "image/png", "image/x-png", "image/gif"], :message => "must be a jpeg, png or gif"
  validates_attachment_size :avatar, :less_than => 1.megabytes, :message => "file size must be less than 1MB"
  validates_attachment_content_type :background_image, :content_type => ["image/jpeg", "image/pjpeg", "image/png", "image/x-png", "image/gif"], :message => "must be a jpeg, png or gif"
  validates_attachment_size :background_image, :less_than => 3.megabytes, :message => "file size must be less than 3MB"
end
