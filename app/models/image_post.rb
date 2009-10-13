class ImagePost < Post 
  has_attached_file :image, :styles => {:default => "400x800>"}, :storage => :s3, :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", :path => ":attachment/:id/:style/:basename.:extension"
end
