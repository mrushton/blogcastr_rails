class ImagePost < Post 
  #MVR - store in either s3 or locally on file
  if Rails.env.production?
    has_attached_file :image, :styles => { :default => "600x400>", :large => "1000x700>" }, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :path => ":attachment/:id/:style/:basename.:extension", :processors => [ :auto_orient, :thumbnail ]
  else
    has_attached_file :image, :styles => { :default => "600x400>", :large => "1000x700>" }, :processors => [ :auto_orient, :thumbnail ]
  end
end
