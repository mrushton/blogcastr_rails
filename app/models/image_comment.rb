class ImageComment < ActiveRecord::Base
  has_attached_file :image, :styles => {:default => "200x400>"}
end
