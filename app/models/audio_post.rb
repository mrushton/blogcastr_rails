class AudioPost < Post 
  #MVR - store in either s3 or locally on file
  if Rails.env.production?
    has_attached_file :audio, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :path => ":attachment/:id/:style/:basename.:extension"
  else
    has_attached_file :audio
  end
  #MVR - paperclip validations need to come after has_attached_file
  validates_attachment_content_type :audio, :content_type => ["audio/mpeg"], :message => "must be a mp3"
  validates_attachment_size :audio, :less_than => 10.megabytes, :message => "file size must be less than 10MB"
end
